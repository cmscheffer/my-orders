# 🚀 Guia Completo de Deploy na Vultr

## 📋 Índice

1. [Pré-requisitos](#pré-requisitos)
2. [Criar Servidor na Vultr](#criar-servidor-na-vultr)
3. [Configuração Inicial do Servidor](#configuração-inicial-do-servidor)
4. [Instalar Dependências](#instalar-dependências)
5. [Configurar PostgreSQL](#configurar-postgresql)
6. [Configurar Aplicação Rails](#configurar-aplicação-rails)
7. [Configurar Nginx](#configurar-nginx)
8. [Configurar SSL (HTTPS)](#configurar-ssl-https)
9. [Automatizar com Systemd](#automatizar-com-systemd)
10. [Manutenção e Monitoramento](#manutenção-e-monitoramento)
11. [Troubleshooting](#troubleshooting)

---

## 🎯 Pré-requisitos

- [ ] Conta na Vultr (https://www.vultr.com)
- [ ] Domínio próprio (opcional, mas recomendado)
- [ ] Cliente SSH (Terminal no Linux/Mac, PuTTY no Windows)
- [ ] Código no GitHub

---

## 🖥️ Criar Servidor na Vultr

### 1. Escolher Plano

**Recomendações:**

| Plano | vCPU | RAM | Disco | Preço/mês | Uso Recomendado |
|-------|------|-----|-------|-----------|-----------------|
| **Starter** | 1 | 1 GB | 25 GB SSD | $6 | Testes/Desenvolvimento |
| **Basic** | 1 | 2 GB | 55 GB SSD | $12 | Produção pequena (10-50 usuários) |
| **Standard** | 2 | 4 GB | 80 GB SSD | $24 | Produção média (50-200 usuários) |

**Recomendo:** **Basic ($12/mês)** - RAM suficiente para Rails + PostgreSQL

### 2. Configurações do Servidor

1. **Acesse:** https://my.vultr.com
2. **Clique:** "Deploy New Server"
3. **Escolha:**
   - **Server Type:** Cloud Compute - Shared CPU
   - **Location:** Escolha mais próxima (ex: São Paulo, Brasil)
   - **Image:** Ubuntu 22.04 LTS x64
   - **Server Size:** $12/mo (2GB RAM) ✅
   - **Additional Features:**
     - ✅ Enable IPv6
     - ✅ Enable Auto Backups ($1.20/mo extra - recomendado)
   - **Server Hostname:** `my-orders-production`
   - **Label:** My Orders - Production

4. **Clique:** "Deploy Now"

5. **Aguarde:** 2-5 minutos (servidor será provisionado)

6. **Copie:** IP do servidor (ex: `123.45.67.89`)

---

## 🔐 Configuração Inicial do Servidor

### 1. Conectar via SSH

```bash
# Substitua pelo IP do seu servidor
ssh root@123.45.67.89

# Se pedir senha, copie do painel da Vultr
```

### 2. Atualizar Sistema

```bash
apt update
apt upgrade -y
```

### 3. Criar Usuário Deploy (Segurança)

```bash
# Criar usuário
adduser deploy
# Defina uma senha forte quando solicitado

# Adicionar ao grupo sudo
usermod -aG sudo deploy

# Testar sudo
su - deploy
sudo ls
# Digite a senha do usuário deploy
```

### 4. Configurar SSH para Deploy

```bash
# Como usuário deploy
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Copiar chaves SSH do root (se houver)
sudo cp /root/.ssh/authorized_keys ~/.ssh/ 2>/dev/null || true
sudo chown deploy:deploy ~/.ssh/authorized_keys 2>/dev/null || true
chmod 600 ~/.ssh/authorized_keys 2>/dev/null || true
```

### 5. Configurar Firewall

```bash
# Como root ou com sudo
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
sudo ufw status
```

---

## 📦 Instalar Dependências

### 1. Instalar Ruby via rbenv

```bash
# Como usuário deploy
cd ~

# Instalar dependências
sudo apt install -y git curl libssl-dev libreadline-dev zlib1g-dev \
  autoconf bison build-essential libyaml-dev libreadline-dev \
  libncurses5-dev libffi-dev libgdbm-dev

# Instalar rbenv
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-installer | bash

# Adicionar ao PATH
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

# Verificar instalação
rbenv --version

# Instalar Ruby 3.2.0
rbenv install 3.2.0
rbenv global 3.2.0

# Verificar
ruby -v  # Deve mostrar: ruby 3.2.0
```

### 2. Instalar Bundler

```bash
gem install bundler
bundler --version
```

### 3. Instalar Node.js (para assets)

```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
node -v  # Deve mostrar: v18.x.x
```

### 4. Instalar Yarn (gerenciador de pacotes)

```bash
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install -y yarn
yarn --version
```

---

## 🗄️ Configurar PostgreSQL

### 1. Instalar PostgreSQL

```bash
sudo apt install -y postgresql postgresql-contrib libpq-dev
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### 2. Criar Banco de Dados e Usuário

```bash
# Entrar como postgres
sudo -u postgres psql

# No prompt do PostgreSQL, execute:
```

```sql
-- Criar usuário
CREATE USER deploy WITH PASSWORD 'SenhaSuperSegura@123';

-- Criar banco de dados
CREATE DATABASE service_orders_production OWNER deploy;

-- Dar permissões
GRANT ALL PRIVILEGES ON DATABASE service_orders_production TO deploy;

-- Sair
\q
```

### 3. Testar Conexão

```bash
psql -U deploy -d service_orders_production -h localhost
# Digite a senha quando solicitado
# Se conectar com sucesso, digite \q para sair
```

---

## ⚙️ Configurar Aplicação Rails

### 1. Clonar Repositório

```bash
cd /home/deploy
git clone https://github.com/cmscheffer/my-orders.git
cd my-orders

# Ou se preferir pasta diferente:
# sudo mkdir -p /var/www
# sudo chown deploy:deploy /var/www
# cd /var/www
# git clone https://github.com/cmscheffer/my-orders.git app
# cd app
```

### 2. Configurar Variáveis de Ambiente

```bash
# Criar arquivo de ambiente
nano .env.production

# Cole o conteúdo abaixo (ajuste os valores):
```

```bash
# .env.production
RAILS_ENV=production
RACK_ENV=production

# Database
DATABASE_URL=postgresql://deploy:SenhaSuperSegura@123@localhost/service_orders_production

# Secret Key Base (gere um novo)
SECRET_KEY_BASE=COLE_AQUI_O_SECRET_GERADO

# Rails Master Key (do config/master.key)
RAILS_MASTER_KEY=COLE_AQUI_SUA_MASTER_KEY

# Host
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
```

**Gerar SECRET_KEY_BASE:**

```bash
# No servidor
cd /home/deploy/my-orders
bundle exec rails secret
# Copie o output e cole no .env.production
```

### 3. Atualizar Gemfile para Produção

```bash
nano Gemfile

# Certifique-se que tem:
# group :production do
#   gem "pg", "~> 1.5"
# end
```

### 4. Instalar Gems

```bash
bundle config set --local deployment 'true'
bundle config set --local without 'development test'
bundle install
```

### 5. Configurar Database.yml

```bash
nano config/database.yml
```

Adicione/ajuste a seção `production`:

```yaml
production:
  <<: *default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  url: <%= ENV['DATABASE_URL'] %>
```

### 6. Preparar Banco de Dados

```bash
# Carregar variáveis de ambiente
export $(cat .env.production | xargs)

# Criar estrutura do banco
bundle exec rails db:create RAILS_ENV=production
bundle exec rails db:migrate RAILS_ENV=production

# Popular com dados iniciais (se tiver seeds)
bundle exec rails db:seed RAILS_ENV=production
```

### 7. Compilar Assets

```bash
bundle exec rails assets:precompile RAILS_ENV=production
```

### 8. Criar Usuário Admin Inicial

```bash
bundle exec rails console production

# No console Rails:
User.create!(
  name: 'Administrador',
  email: 'admin@seudominio.com',
  password: 'SenhaSuperSegura@123',
  password_confirmation: 'SenhaSuperSegura@123',
  role: 'admin'
)
exit
```

---

## 🌐 Configurar Nginx

### 1. Instalar Nginx

```bash
sudo apt install -y nginx
```

### 2. Configurar Site

```bash
sudo nano /etc/nginx/sites-available/my-orders
```

Cole a configuração:

```nginx
upstream puma {
  server unix:///home/deploy/my-orders/shared/sockets/puma.sock;
}

server {
  listen 80;
  listen [::]:80;
  
  # Substitua pelo seu domínio
  server_name seudominio.com www.seudominio.com;
  
  # Ou use o IP se não tiver domínio
  # server_name 123.45.67.89;
  
  root /home/deploy/my-orders/public;
  access_log /var/log/nginx/my-orders_access.log;
  error_log /var/log/nginx/my-orders_error.log info;
  
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
  
  error_page 500 502 503 504 /500.html;
  client_max_body_size 10M;
  keepalive_timeout 10;
}
```

### 3. Ativar Site

```bash
# Criar link simbólico
sudo ln -s /etc/nginx/sites-available/my-orders /etc/nginx/sites-enabled/

# Remover site padrão
sudo rm /etc/nginx/sites-enabled/default

# Testar configuração
sudo nginx -t

# Se OK, reiniciar
sudo systemctl restart nginx
```

---

## 🔒 Configurar SSL (HTTPS)

### 1. Instalar Certbot

```bash
sudo apt install -y certbot python3-certbot-nginx
```

### 2. Obter Certificado SSL

```bash
# Substitua pelo seu domínio
sudo certbot --nginx -d seudominio.com -d www.seudominio.com

# Siga as instruções:
# - Digite seu email
# - Aceite os termos
# - Escolha se quer compartilhar email (opcional)
# - Escolha opção 2 (redirecionar HTTP para HTTPS)
```

### 3. Renovação Automática

```bash
# Testar renovação
sudo certbot renew --dry-run

# Certbot já configura renovação automática via cron
```

---

## 🤖 Automatizar com Systemd

### 1. Criar Serviço Puma

```bash
sudo nano /etc/systemd/system/puma.service
```

Cole:

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

### 2. Configurar Puma

```bash
nano config/puma.rb
```

Ajuste para produção:

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

# Para usar socket Unix (melhor performance)
if ENV["RAILS_ENV"] == "production"
  bind "unix:///home/deploy/my-orders/shared/sockets/puma.sock"
else
  bind "tcp://0.0.0.0:3000"
end
```

### 3. Criar Diretórios Necessários

```bash
mkdir -p /home/deploy/my-orders/shared/sockets
mkdir -p /home/deploy/my-orders/log
```

### 4. Ativar e Iniciar Serviço

```bash
sudo systemctl daemon-reload
sudo systemctl enable puma
sudo systemctl start puma

# Verificar status
sudo systemctl status puma

# Ver logs
sudo journalctl -u puma -f
```

---

## 📊 Manutenção e Monitoramento

### Scripts Úteis

Crie um script de deploy:

```bash
nano ~/deploy.sh
chmod +x ~/deploy.sh
```

```bash
#!/bin/bash
# ~/deploy.sh

echo "🚀 Iniciando deploy..."

cd /home/deploy/my-orders

echo "📥 Atualizando código..."
git pull origin main

echo "📦 Instalando dependências..."
bundle install --deployment --without development test

echo "🗄️ Migrando banco de dados..."
export $(cat .env.production | xargs)
bundle exec rails db:migrate RAILS_ENV=production

echo "🎨 Compilando assets..."
bundle exec rails assets:precompile RAILS_ENV=production

echo "🔄 Reiniciando servidor..."
sudo systemctl restart puma

echo "✅ Deploy concluído!"
echo "🌐 Acesse: http://seudominio.com"
```

### Comandos Úteis

```bash
# Ver logs do Puma
tail -f /home/deploy/my-orders/log/puma.stdout.log
tail -f /home/deploy/my-orders/log/puma.stderr.log

# Ver logs do Rails
tail -f /home/deploy/my-orders/log/production.log

# Ver logs do Nginx
sudo tail -f /var/log/nginx/my-orders_access.log
sudo tail -f /var/log/nginx/my-orders_error.log

# Reiniciar serviços
sudo systemctl restart puma
sudo systemctl restart nginx

# Verificar status
sudo systemctl status puma
sudo systemctl status nginx
sudo systemctl status postgresql

# Verificar uso de recursos
htop
df -h  # espaço em disco
free -h  # memória
```

---

## 🔧 Troubleshooting

### Problema: Puma não inicia

```bash
# Ver logs detalhados
sudo journalctl -u puma -n 100 --no-pager

# Verificar permissões
ls -la /home/deploy/my-orders/shared/sockets/

# Testar manualmente
cd /home/deploy/my-orders
export $(cat .env.production | xargs)
bundle exec puma -C config/puma.rb
```

### Problema: 502 Bad Gateway (Nginx)

```bash
# Verificar se Puma está rodando
sudo systemctl status puma

# Verificar socket
ls -la /home/deploy/my-orders/shared/sockets/puma.sock

# Ver logs do Nginx
sudo tail -50 /var/log/nginx/my-orders_error.log
```

### Problema: Erro de Banco de Dados

```bash
# Testar conexão PostgreSQL
psql -U deploy -d service_orders_production -h localhost

# Verificar DATABASE_URL
cat .env.production | grep DATABASE_URL

# Recriar banco (CUIDADO: apaga dados!)
bundle exec rails db:drop db:create db:migrate RAILS_ENV=production
```

### Problema: Assets não carregam

```bash
# Recompilar assets
bundle exec rails assets:clobber RAILS_ENV=production
bundle exec rails assets:precompile RAILS_ENV=production

# Verificar permissões
ls -la public/assets/

# Reiniciar Nginx
sudo systemctl restart nginx
```

---

## 📝 Checklist Final

Antes de considerar deploy completo, verifique:

- [ ] Servidor criado e acessível via SSH
- [ ] Firewall configurado (portas 80, 443, 22)
- [ ] Ruby e dependências instaladas
- [ ] PostgreSQL rodando e banco criado
- [ ] Código clonado do GitHub
- [ ] Variáveis de ambiente configuradas
- [ ] Migrations executadas
- [ ] Assets compilados
- [ ] Usuário admin criado
- [ ] Nginx instalado e configurado
- [ ] SSL/HTTPS configurado (se tiver domínio)
- [ ] Puma rodando como serviço
- [ ] Site acessível via navegador
- [ ] Login funciona
- [ ] Criar usuário funciona
- [ ] Todas funcionalidades testadas
- [ ] Backups configurados (Vultr Auto Backups)
- [ ] Script de deploy criado

---

## 🎉 Deploy Concluído!

Seu sistema está no ar em: **https://seudominio.com**

**Credenciais de acesso:**
- Email: admin@seudominio.com
- Senha: (a que você definiu)

**Próximos passos:**
1. Altere senha do admin
2. Crie usuários adicionais
3. Configure domínio personalizado (se não fez)
4. Configure backups adicionais (dump do banco)
5. Configure monitoramento (Uptime Robot, etc)

---

## 📚 Recursos Adicionais

- **Vultr Docs:** https://www.vultr.com/docs/
- **Rails Deployment:** https://guides.rubyonrails.org/deployment.html
- **Puma:** https://github.com/puma/puma
- **Nginx:** https://nginx.org/en/docs/
- **Let's Encrypt:** https://letsencrypt.org/docs/

---

**Dúvidas?** Consulte a documentação ou abra uma issue no GitHub!
