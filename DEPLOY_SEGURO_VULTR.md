# 🚀 DEPLOY SEGURO - VULTR (GERANDO CHAVES NA HORA)

## 🔒 SEGURANÇA PRIMEIRO

Este guia ensina a **GERAR AS CHAVES DE PRODUÇÃO NO MOMENTO DO DEPLOY**, garantindo que apenas você terá acesso a elas.

**⚠️ NUNCA use chaves de exemplo ou de documentação em produção!**

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
```

**No prompt do PostgreSQL, execute:**

```sql
-- IMPORTANTE: Troque 'SuaSenhaForteAqui' por uma senha real e forte
CREATE USER deploy WITH PASSWORD 'SuaSenhaForteAqui';
CREATE DATABASE service_orders_production OWNER deploy;
GRANT ALL PRIVILEGES ON DATABASE service_orders_production TO deploy;

-- Sair
\q
```

**⚠️ ANOTE A SENHA DO POSTGRESQL - Você vai precisar dela!**

### 3.3 Testar Conexão

```bash
# Teste a conexão (use a senha que você definiu)
psql -U deploy -d service_orders_production -h localhost -W
# Digite a senha
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

### 4.2 🔑 GERAR CHAVES DE SEGURANÇA (IMPORTANTE!)

**Este é o momento de gerar suas chaves únicas de produção:**

```bash
# Gerar SECRET_KEY_BASE
echo "SECRET_KEY_BASE=$(openssl rand -hex 64)"

# Gerar RAILS_MASTER_KEY
echo "RAILS_MASTER_KEY=$(openssl rand -hex 32)"
```

**⚠️ COPIE E GUARDE ESTAS DUAS CHAVES EM LOCAL SEGURO!**
- Cole em um gerenciador de senhas
- Ou anote em papel e guarde em cofre
- Você NÃO conseguirá recuperá-las depois!

### 4.3 Criar arquivo .env.production

```bash
nano .env.production
```

**Cole este template e PREENCHA os valores:**

```bash
# === CHAVES DE SEGURANÇA ===
# Cole aqui a SECRET_KEY_BASE gerada no passo 4.2
SECRET_KEY_BASE=COLE_AQUI_SUA_SECRET_KEY_BASE_GERADA

# Cole aqui a RAILS_MASTER_KEY gerada no passo 4.2
RAILS_MASTER_KEY=COLE_AQUI_SUA_RAILS_MASTER_KEY_GERADA

# === BANCO DE DADOS ===
# Troque pela senha do PostgreSQL que você criou no passo 3.2
# Formato: postgresql://usuario:senha@host/database
# Se sua senha tiver caracteres especiais, codifique-os:
# % = %25, @ = %40, : = %3A, / = %2F
DATABASE_URL=postgresql://deploy:SuaSenhaPostgreSQL@localhost/service_orders_production

# === RAILS ===
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
RAILS_MAX_THREADS=5
WEB_CONCURRENCY=2

# === DEVISE (Adicionar depois se tiver domínio) ===
# DEVISE_MAILER_HOST=seu-dominio.com
```

**Exemplo preenchido (SEUS VALORES SERÃO DIFERENTES):**

```bash
SECRET_KEY_BASE=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2g3h4i5j6k7l8m9n0o1p2q3r4s5t6u7v8w9x0y1z2a3b4c5d6e7f8g9h0i1j2k3l4m5n6
RAILS_MASTER_KEY=z9y8x7w6v5u4t3s2r1q0p9o8n7m6l5k4j3i2h1g0f9e8d7c6b5a4
DATABASE_URL=postgresql://deploy:MinhaS3nh@Fort3@localhost/service_orders_production
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
RAILS_MAX_THREADS=5
WEB_CONCURRENCY=2
```

**Salvar:** `Ctrl+X` → `Y` → `Enter`

**Proteger arquivo:**
```bash
chmod 600 .env.production
```

### 4.4 Criar config/master.key no Servidor

```bash
# Extrair apenas a MASTER_KEY do .env.production e criar o arquivo
grep RAILS_MASTER_KEY .env.production | cut -d'=' -f2 > config/master.key
chmod 600 config/master.key

# Verificar se foi criado corretamente
cat config/master.key
# Deve mostrar a mesma chave que você colocou no .env.production
```

### 4.5 Instalar Gems

```bash
bundle install --without development test
```

**Se der erro de pg gem:**
```bash
sudo apt-get install -y libpq-dev
bundle install --without development test
```

### 4.6 Carregar Variáveis de Ambiente

```bash
set -a
source .env.production
set +a

# Verificar se carregou
echo $RAILS_ENV
# Deve mostrar: production

echo ${SECRET_KEY_BASE:0:20}...
# Deve mostrar os primeiros 20 caracteres da sua chave
```

### 4.7 Setup do Banco de Dados

```bash
# Criar banco (pode dar erro se já criou manualmente, ignore)
bundle exec rails db:create RAILS_ENV=production

# Rodar migrations
bundle exec rails db:migrate RAILS_ENV=production

# Popular dados iniciais (cria usuário admin)
bundle exec rails db:seed RAILS_ENV=production
```

**Usuário admin criado:**
- Email: `admin@example.com`
- Senha: `Admin@123`

**⚠️ TROCAR ESTA SENHA DEPOIS DO PRIMEIRO LOGIN!**

### 4.8 Compilar Assets

```bash
bundle exec rails assets:precompile RAILS_ENV=production
```

### 4.9 Criar Diretórios Necessários

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

**Se der erro, verificar logs:**
```bash
sudo journalctl -u my-orders -n 50
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

**Cole (AJUSTE O IP/DOMÍNIO depois):**

```nginx
upstream puma {
  server unix:///home/deploy/my-orders/shared/sockets/puma.sock;
}

server {
  listen 80;
  listen [::]:80;
  
  # OPÇÃO 1: Se tiver domínio, troque depois por:
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

**⚠️ TROCAR ESTA SENHA IMEDIATAMENTE!**

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

## 🔒 SEGURANÇA PÓS-DEPLOY (OBRIGATÓRIO)

### 1. Trocar Senha do Admin

```bash
cd ~/my-orders
bundle exec rails console production
```

**No console Rails:**
```ruby
admin = User.find_by(email: 'admin@example.com')
admin.password = 'SuaNovaSenhaForte@123'
admin.password_confirmation = 'SuaNovaSenhaForte@123'
admin.save!
exit
```

### 2. Atualizar Email do Admin

- Fazer login na aplicação
- Ir em "Editar Perfil"
- Trocar email para seu email real

### 3. Configurar Backups Automáticos

```bash
# Criar diretório de backups
mkdir -p ~/backups

# Configurar cron para backup diário
crontab -e
```

**Adicionar esta linha (backup diário às 2h da manhã):**
```bash
0 2 * * * pg_dump -U deploy -h localhost service_orders_production > /home/deploy/backups/db_$(date +\%Y\%m\%d).sql
```

### 4. Criar Script de Limpeza de Backups Antigos

```bash
nano ~/cleanup_backups.sh
```

**Cole:**
```bash
#!/bin/bash
# Manter apenas backups dos últimos 30 dias
find /home/deploy/backups -name "db_*.sql" -mtime +30 -delete
```

**Tornar executável:**
```bash
chmod +x ~/cleanup_backups.sh
```

**Adicionar ao cron (diariamente às 3h):**
```bash
crontab -e
```

**Adicionar:**
```bash
0 3 * * * /home/deploy/cleanup_backups.sh
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

# Recarregar variáveis
set -a
source .env.production
set +a

# Instalar gems (se houver novas)
bundle install --without development test

# Rodar migrations (se houver novas)
bundle exec rails db:migrate RAILS_ENV=production

# Recompilar assets
bundle exec rails assets:precompile RAILS_ENV=production

# Reiniciar
sudo systemctl start my-orders
```

### Backup Manual do Banco

```bash
# Criar backup
pg_dump -U deploy -h localhost service_orders_production > ~/backups/backup_manual_$(date +%Y%m%d_%H%M%S).sql

# Restaurar backup
psql -U deploy -h localhost service_orders_production < ~/backups/backup_manual_20250105_123456.sql
```

### Ver Usuários do Banco

```bash
cd ~/my-orders
bundle exec rails console production
```

**No console:**
```ruby
User.all
User.where(role: 'admin')
exit
```

---

## ✅ CHECKLIST FINAL

- [ ] Servidor configurado e atualizado
- [ ] Usuário deploy criado
- [ ] Firewall configurado (UFW)
- [ ] Ruby 3.2.0 instalado via rbenv
- [ ] PostgreSQL instalado e configurado
- [ ] Banco de dados criado
- [ ] Repositório clonado
- [ ] **Chaves de segurança GERADAS e GUARDADAS** ⚠️
- [ ] .env.production criado e protegido (chmod 600)
- [ ] config/master.key criado e protegido
- [ ] Gems instaladas
- [ ] Migrations executadas
- [ ] Seeds executados (usuário admin criado)
- [ ] Assets compilados
- [ ] Puma configurado
- [ ] Serviço systemd criado e ativo
- [ ] Nginx instalado e configurado
- [ ] Aplicação acessível via IP
- [ ] Login funcionando
- [ ] **Senha do admin trocada** ⚠️
- [ ] **Email do admin atualizado** ⚠️
- [ ] **Backups automáticos configurados** ⚠️
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

# Verificar se a senha no DATABASE_URL está correta
grep DATABASE_URL ~/my-orders/.env.production
```

### Erro: "Puma socket not found"

```bash
# Verificar se serviço está rodando
sudo systemctl status my-orders

# Ver logs detalhados
sudo journalctl -u my-orders -n 100

# Verificar socket
ls -la ~/my-orders/shared/sockets/

# Reiniciar
sudo systemctl restart my-orders
```

### Erro: "502 Bad Gateway" no Nginx

```bash
# Verificar se Puma está rodando
sudo systemctl status my-orders

# Verificar socket do Puma
ls -la ~/my-orders/shared/sockets/puma.sock

# Ver logs do Nginx
sudo tail -f /var/log/nginx/my-orders_error.log

# Ver logs da aplicação
tail -f ~/my-orders/log/production.log

# Reiniciar tudo
sudo systemctl restart my-orders
sudo systemctl restart nginx
```

### Erro: "ActiveSupport::MessageEncryptor::InvalidMessage"

```bash
# Verificar se RAILS_MASTER_KEY está correta
cat ~/my-orders/config/master.key
grep RAILS_MASTER_KEY ~/my-orders/.env.production

# As duas devem ter o mesmo valor!
# Se diferentes, corrigir:
grep RAILS_MASTER_KEY ~/my-orders/.env.production | cut -d'=' -f2 > ~/my-orders/config/master.key
chmod 600 ~/my-orders/config/master.key

# Reiniciar
sudo systemctl restart my-orders
```

### Erro: "Database does not exist"

```bash
cd ~/my-orders
set -a
source .env.production
set +a
bundle exec rails db:create RAILS_ENV=production
bundle exec rails db:migrate RAILS_ENV=production
bundle exec rails db:seed RAILS_ENV=production
```

### Erro: Caracteres especiais na senha do PostgreSQL

Se sua senha tem `%`, `@`, `:`, etc., codifique-os no DATABASE_URL:

| Caractere | Código |
|-----------|--------|
| `%` | `%25` |
| `@` | `%40` |
| `:` | `%3A` |
| `/` | `%2F` |

**Exemplo:**
- Senha: `Minha@Senh%123`
- No DATABASE_URL: `postgresql://deploy:Minha%40Senh%25123@localhost/...`

---

## 🎉 PRONTO!

Sua aplicação está no ar em produção com chaves de segurança únicas! 🚀

**URLs:**
- HTTP: `http://SEU_IP_VULTR`
- HTTPS (se configurou): `https://seudominio.com`

**Login admin:**
- Email: O que você definiu (originalmente `admin@example.com`)
- Senha: A que você trocou (originalmente `Admin@123`)

---

## 💡 DICAS FINAIS

1. **Monitore os logs regularmente:**
   ```bash
   tail -f ~/my-orders/log/production.log
   ```

2. **Mantenha o sistema atualizado:**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

3. **Teste backups periodicamente:**
   ```bash
   ls -lh ~/backups/
   ```

4. **Configure alertas de erro (opcional):**
   - Considere usar serviços como Sentry, Rollbar, ou Honeybadger

5. **Documente suas configurações:**
   - Anote senhas, IPs, domínios em local seguro
   - Guarde as chaves de produção em gerenciador de senhas

---

**Data de criação:** 2025-01-05  
**Versão:** 1.0 - Deploy seguro com geração de chaves na hora
