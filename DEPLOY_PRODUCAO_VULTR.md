# 🚀 DEPLOY DE PRODUÇÃO - VULTR (DO ZERO)

## 🔑 CHAVES DE PRODUÇÃO

**⚠️ GUARDE ESTAS CHAVES EM LOCAL SEGURO!**

### SECRET_KEY_BASE (Produção)
```
f0aebba538a2d75a57ad647bda57b12716e349b82a27fc0191a31db925d5f47085c69f1fd0c28897ce38cd910857a8b727e0b4c9e6ad70cd60e1ff59786b1e2d
```

### RAILS_MASTER_KEY (Produção)
```
749606f7c4dae30fa40a366fac471656de4d65657636c534111a6ca694688db6
```

---

## 📋 PRÉ-REQUISITOS

- Servidor Vultr Ubuntu 22.04 LTS criado
- IP do servidor (ex: 45.76.123.45)
- Acesso SSH root configurado

---

## FASE 1: CONFIGURAÇÃO INICIAL DO SERVIDOR

### 1.1 Conectar ao Servidor

```bash
# Na sua máquina local:
ssh root@SEU_IP_VULTR

# Exemplo:
ssh root@45.76.123.45
```

### 1.2 Atualizar Sistema

```bash
apt update
apt upgrade -y
apt install -y curl git build-essential libssl-dev libreadline-dev zlib1g-dev \
  libpq-dev postgresql-client software-properties-common
```

### 1.3 Criar Usuário Deploy

```bash
# Criar usuário
adduser deploy
# Defina uma senha forte quando solicitado

# Adicionar ao grupo sudo
usermod -aG sudo deploy

# Configurar SSH para o usuário deploy
mkdir -p /home/deploy/.ssh
cp ~/.ssh/authorized_keys /home/deploy/.ssh/
chown -R deploy:deploy /home/deploy/.ssh
chmod 700 /home/deploy/.ssh
chmod 600 /home/deploy/.ssh/authorized_keys
```

### 1.4 Configurar Firewall

```bash
# Instalar UFW
apt install -y ufw

# Permitir SSH, HTTP e HTTPS
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

# Ativar firewall
ufw --force enable

# Verificar status
ufw status
```

### 1.5 Trocar para Usuário Deploy

```bash
# A partir daqui, usar o usuário deploy
su - deploy
```

---

## FASE 2: INSTALAR RUBY VIA RBENV

### 2.1 Instalar rbenv

```bash
# Clonar rbenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv

# Adicionar ao PATH
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc

# Recarregar
source ~/.bashrc

# Verificar instalação
rbenv -v
```

### 2.2 Instalar ruby-build

```bash
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
```

### 2.3 Instalar Ruby 3.2.0

```bash
# Instalar Ruby (demora ~10 minutos)
rbenv install 3.2.0

# Definir como global
rbenv global 3.2.0

# Verificar
ruby -v
# Deve mostrar: ruby 3.2.0
```

### 2.4 Instalar Bundler

```bash
gem install bundler
rbenv rehash
```

---

## FASE 3: INSTALAR E CONFIGURAR POSTGRESQL

### 3.1 Instalar PostgreSQL

```bash
sudo apt install -y postgresql postgresql-contrib
```

### 3.2 Criar Usuário e Banco de Dados

```bash
# Conectar como postgres
sudo -u postgres psql

# No prompt do PostgreSQL, execute:
CREATE USER deploy WITH PASSWORD 'SenhaSuperSegura123';
CREATE DATABASE service_orders_production OWNER deploy;
GRANT ALL PRIVILEGES ON DATABASE service_orders_production TO deploy;

# Sair
\q
```

### 3.3 Testar Conexão

```bash
psql -U deploy -d service_orders_production -h localhost -W
# Digite a senha: SenhaSuperSegura123
# Se conectar, digite \q para sair
```

---

## FASE 4: CLONAR E CONFIGURAR APLICAÇÃO

### 4.1 Clonar Repositório

```bash
cd ~
git clone https://github.com/cmscheffer/my-orders.git
cd my-orders
```

### 4.2 Criar arquivo .env.production

```bash
nano .env.production
```

**Cole EXATAMENTE este conteúdo:**

```bash
SECRET_KEY_BASE=f0aebba538a2d75a57ad647bda57b12716e349b82a27fc0191a31db925d5f47085c69f1fd0c28897ce38cd910857a8b727e0b4c9e6ad70cd60e1ff59786b1e2d
RAILS_MASTER_KEY=749606f7c4dae30fa40a366fac471656de4d65657636c534111a6ca694688db6
DATABASE_URL=postgresql://deploy:SenhaSuperSegura123@localhost/service_orders_production
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
RAILS_MAX_THREADS=5
WEB_CONCURRENCY=2
```

**⚠️ AJUSTAR DEPOIS (Fase 7):**
- Quando tiver domínio, adicionar: `DEVISE_MAILER_HOST=seu-dominio.com`

**Salvar:** `Ctrl+X` → `Y` → `Enter`

**Proteger arquivo:**
```bash
chmod 600 .env.production
```

### 4.3 Criar config/master.key no Servidor

```bash
echo "749606f7c4dae30fa40a366fac471656de4d65657636c534111a6ca694688db6" > config/master.key
chmod 600 config/master.key
```

### 4.4 Instalar Gems

```bash
bundle install --without development test
```

**Se der erro de pg gem:**
```bash
sudo apt-get install -y libpq-dev
bundle install --without development test
```

### 4.5 Carregar Variáveis de Ambiente

```bash
set -a
source .env.production
set +a

# Verificar
echo $RAILS_ENV
# Deve mostrar: production
```

### 4.6 Setup do Banco de Dados

```bash
# Criar banco (se não criou manualmente)
bundle exec rails db:create RAILS_ENV=production

# Rodar migrations
bundle exec rails db:migrate RAILS_ENV=production

# Popular dados iniciais (cria usuário admin)
bundle exec rails db:seed RAILS_ENV=production
```

**Usuário admin criado:**
- Email: `admin@example.com`
- Senha: `Admin@123`

### 4.7 Compilar Assets

```bash
bundle exec rails assets:precompile RAILS_ENV=production
```

### 4.8 Criar Diretórios Necessários

```bash
mkdir -p shared/sockets
mkdir -p log
mkdir -p tmp/pids
```

---

## FASE 5: CONFIGURAR PUMA

### 5.1 Editar config/puma.rb

```bash
nano config/puma.rb
```

**Substituir TODO o conteúdo por:**

```ruby
# config/puma.rb
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "production" }
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

preload_app!

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

plugin :tmp_restart

# Para produção: socket Unix (melhor performance)
if ENV["RAILS_ENV"] == "production"
  bind "unix:///home/deploy/my-orders/shared/sockets/puma.sock"
else
  bind "tcp://0.0.0.0:3000"
end
```

**Salvar:** `Ctrl+X` → `Y` → `Enter`

---

## FASE 6: CONFIGURAR SYSTEMD

### 6.1 Criar Serviço

```bash
sudo nano /etc/systemd/system/my-orders.service
```

**Cole:**

```ini
[Unit]
Description=Puma HTTP Server for My Orders
After=network.target postgresql.service

[Service]
Type=simple
User=deploy
WorkingDirectory=/home/deploy/my-orders
EnvironmentFile=/home/deploy/my-orders/.env.production

ExecStart=/home/deploy/.rbenv/shims/bundle exec puma -C config/puma.rb
ExecReload=/bin/kill -USR1 $MAINPID

Restart=always
RestartSec=10

StandardOutput=append:/home/deploy/my-orders/log/puma.stdout.log
StandardError=append:/home/deploy/my-orders/log/puma.stderr.log

[Install]
WantedBy=multi-user.target
```

**Salvar:** `Ctrl+X` → `Y` → `Enter`

### 6.2 Ativar e Iniciar Serviço

```bash
# Recarregar systemd
sudo systemctl daemon-reload

# Habilitar para iniciar no boot
sudo systemctl enable my-orders

# Iniciar serviço
sudo systemctl start my-orders

# Verificar status
sudo systemctl status my-orders
```

**Deve mostrar:** `Active: active (running)`

### 6.3 Ver Logs

```bash
# Logs do systemd
sudo journalctl -u my-orders -f

# Ou logs diretos
tail -f ~/my-orders/log/production.log
```

---

## FASE 7: INSTALAR E CONFIGURAR NGINX

### 7.1 Instalar Nginx

```bash
sudo apt install -y nginx
```

### 7.2 Configurar Site

```bash
sudo nano /etc/nginx/sites-available/my-orders
```

**Cole (AJUSTE O IP/DOMÍNIO):**

```nginx
upstream puma {
  server unix:///home/deploy/my-orders/shared/sockets/puma.sock;
}

server {
  listen 80;
  listen [::]:80;
  
  # OPÇÃO 1: Se tiver domínio, use:
  # server_name seudominio.com www.seudominio.com;
  
  # OPÇÃO 2: Se só tiver IP, use:
  server_name _;
  
  root /home/deploy/my-orders/public;
  access_log /var/log/nginx/my-orders_access.log;
  error_log /var/log/nginx/my-orders_error.log info;
  
  # Assets estáticos
  location ^~ /assets/ {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
  }
  
  try_files $uri/index.html $uri @puma;
  
  location @puma {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://puma;
  }
  
  # Limite de tamanho de upload
  client_max_body_size 100M;
  
  # Timeout
  proxy_connect_timeout 300;
  proxy_send_timeout 300;
  proxy_read_timeout 300;
  send_timeout 300;
}
```

**Salvar:** `Ctrl+X` → `Y` → `Enter`

### 7.3 Ativar Site

```bash
# Criar link simbólico
sudo ln -s /etc/nginx/sites-available/my-orders /etc/nginx/sites-enabled/

# Remover site padrão
sudo rm -f /etc/nginx/sites-enabled/default

# Testar configuração
sudo nginx -t

# Se OK, reiniciar Nginx
sudo systemctl restart nginx
```

---

## FASE 8: TESTAR APLICAÇÃO

### 8.1 Testar Localmente

```bash
curl http://localhost
```

Deve retornar HTML da aplicação.

### 8.2 Testar do Navegador

Na sua máquina, abra o navegador:

```
http://SEU_IP_VULTR
```

**Exemplo:**
```
http://45.76.123.45
```

### 8.3 Fazer Login

- Email: `admin@example.com`
- Senha: `Admin@123`

---

## FASE 9 (OPCIONAL): CONFIGURAR DOMÍNIO E SSL

### 9.1 Configurar Domínio

**No seu provedor de domínio (ex: GoDaddy, Registro.br):**

1. Adicionar registro tipo `A`:
   - Nome: `@` (ou deixe em branco)
   - Valor: `SEU_IP_VULTR`
   - TTL: 3600

2. Adicionar registro tipo `A` para www:
   - Nome: `www`
   - Valor: `SEU_IP_VULTR`
   - TTL: 3600

**Aguardar propagação DNS (5-30 minutos)**

### 9.2 Atualizar Nginx com Domínio

```bash
sudo nano /etc/nginx/sites-available/my-orders
```

**Trocar a linha `server_name _;` por:**
```nginx
server_name seudominio.com www.seudominio.com;
```

**Reiniciar Nginx:**
```bash
sudo nginx -t
sudo systemctl restart nginx
```

### 9.3 Instalar SSL (Let's Encrypt)

```bash
# Instalar Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obter certificado SSL
sudo certbot --nginx -d seudominio.com -d www.seudominio.com

# Seguir instruções:
# - Digite seu email
# - Aceite os termos
# - Escolha opção 2 (redirecionar HTTP para HTTPS)
```

### 9.4 Atualizar .env.production com Domínio

```bash
nano ~/my-orders/.env.production
```

**Adicionar ao final:**
```bash
DEVISE_MAILER_HOST=seudominio.com
```

**Reiniciar aplicação:**
```bash
sudo systemctl restart my-orders
```

### 9.5 Testar HTTPS

```
https://seudominio.com
```

---

## 📊 COMANDOS ÚTEIS

### Gerenciar Serviço

```bash
# Ver status
sudo systemctl status my-orders

# Parar
sudo systemctl stop my-orders

# Iniciar
sudo systemctl start my-orders

# Reiniciar
sudo systemctl restart my-orders

# Ver logs
sudo journalctl -u my-orders -f
tail -f ~/my-orders/log/production.log
```

### Atualizar Aplicação

```bash
cd ~/my-orders

# Parar serviço
sudo systemctl stop my-orders

# Puxar código
git pull origin main

# Instalar gems (se houver novas)
bundle install --without development test

# Rodar migrations (se houver novas)
bundle exec rails db:migrate RAILS_ENV=production

# Recompilar assets
bundle exec rails assets:precompile RAILS_ENV=production

# Reiniciar
sudo systemctl start my-orders
```

### Backup do Banco de Dados

```bash
# Criar backup
pg_dump -U deploy -h localhost service_orders_production > backup_$(date +%Y%m%d_%H%M%S).sql

# Restaurar backup
psql -U deploy -h localhost service_orders_production < backup_20250105_123456.sql
```

### Ver Usuários do Banco

```bash
bundle exec rails console production

# No console:
User.all
User.where(role: 'admin')
exit
```

---

## ✅ CHECKLIST FINAL

- [ ] Servidor Vultr criado e atualizado
- [ ] Usuário deploy criado
- [ ] Firewall configurado (UFW)
- [ ] Ruby 3.2.0 instalado via rbenv
- [ ] PostgreSQL instalado
- [ ] Banco de dados criado
- [ ] Repositório clonado
- [ ] .env.production criado com chaves de produção
- [ ] config/master.key criado
- [ ] Gems instaladas
- [ ] Migrations executadas
- [ ] Seeds executados (usuário admin criado)
- [ ] Assets compilados
- [ ] Puma configurado
- [ ] Serviço systemd criado e ativo
- [ ] Nginx instalado e configurado
- [ ] Aplicação acessível via IP
- [ ] Login funcionando
- [ ] (Opcional) Domínio configurado
- [ ] (Opcional) SSL configurado

---

## 🆘 TROUBLESHOOTING

### Erro: "Can't connect to PostgreSQL"

```bash
# Verificar se PostgreSQL está rodando
sudo systemctl status postgresql

# Testar conexão
psql -U deploy -d service_orders_production -h localhost -W
```

### Erro: "Puma socket not found"

```bash
# Verificar se serviço está rodando
sudo systemctl status my-orders

# Ver logs
sudo journalctl -u my-orders -n 50

# Reiniciar
sudo systemctl restart my-orders
```

### Erro: "502 Bad Gateway" no Nginx

```bash
# Verificar se Puma está rodando
sudo systemctl status my-orders

# Verificar socket
ls -la ~/my-orders/shared/sockets/puma.sock

# Ver logs do Nginx
sudo tail -f /var/log/nginx/my-orders_error.log
```

### Erro: "Database does not exist"

```bash
cd ~/my-orders
set -a
source .env.production
set +a
bundle exec rails db:create RAILS_ENV=production
bundle exec rails db:migrate RAILS_ENV=production
```

---

## 🎉 PRONTO!

Sua aplicação está no ar em produção! 🚀

**URLs:**
- HTTP: `http://SEU_IP_VULTR`
- HTTPS (se configurou): `https://seudominio.com`

**Login admin:**
- Email: `admin@example.com`
- Senha: `Admin@123`

---

## 🔐 SEGURANÇA PÓS-DEPLOY

1. **Trocar senha do admin:**
   ```bash
   bundle exec rails console production
   
   admin = User.find_by(email: 'admin@example.com')
   admin.password = 'NovaSenhaSuperSegura@456'
   admin.password_confirmation = 'NovaSenhaSuperSegura@456'
   admin.save!
   exit
   ```

2. **Atualizar email do admin:**
   - Fazer login
   - Ir em "Editar Perfil"
   - Trocar email para seu email real

3. **Configurar backups automáticos:**
   ```bash
   crontab -e
   
   # Adicionar (backup diário às 2h da manhã):
   0 2 * * * pg_dump -U deploy -h localhost service_orders_production > /home/deploy/backups/db_$(date +\%Y\%m\%d).sql
   ```

4. **Monitorar logs regularmente:**
   ```bash
   tail -f ~/my-orders/log/production.log
   ```

---

**Data de criação:** 2025-01-05
**Chaves geradas em:** 2025-01-05 (exclusivas para produção)
