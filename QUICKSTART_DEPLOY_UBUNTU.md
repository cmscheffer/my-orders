# ⚡ QUICKSTART DEPLOY - Ubuntu Server 24.04
## Deploy Rápido em 1 Hora

---

## 🎯 OBJETIVO

Deploy completo do Sistema de Ordens + NFE.io em ~1 hora.

**Pré-requisitos:**
- ✅ Servidor Ubuntu 24.04 criado (Vultr, AWS, etc)
- ✅ IP do servidor
- ✅ Conta NFE.io criada
- ✅ API Key e Company ID do NFE.io
- ✅ Código no GitHub

---

## ⏱️ TIMELINE

| Etapa | Tempo | Descrição |
|-------|-------|-----------|
| 1 | 5 min | Configuração inicial |
| 2 | 10 min | Instalar dependências |
| 3 | 5 min | PostgreSQL |
| 4 | 15 min | Deploy Rails |
| 5 | 10 min | Implementar NFE.io |
| 6 | 10 min | Nginx + Puma |
| 7 | 5 min | Testes |
| **TOTAL** | **60 min** | |

---

## 1️⃣ CONFIGURAÇÃO INICIAL (5 min)

```bash
# Conectar
ssh root@SEU_IP

# Atualizar
apt update && apt upgrade -y

# Criar usuário
adduser deploy
usermod -aG sudo deploy

# Firewall
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable

# Trocar para deploy
su - deploy
```

---

## 2️⃣ INSTALAR DEPENDÊNCIAS (10 min)

```bash
# Pacotes básicos
sudo apt install -y git curl build-essential libssl-dev \
  libreadline-dev zlib1g-dev libpq-dev

# Ruby via rbenv
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-installer | bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

rbenv install 3.2.0
rbenv global 3.2.0

# Bundler e Rails
gem install bundler rails -v 7.1.6

# Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install -y yarn
```

---

## 3️⃣ POSTGRESQL (5 min)

```bash
# Instalar
sudo apt install -y postgresql postgresql-contrib

# Criar banco
sudo -u postgres psql << EOF
CREATE USER deploy WITH PASSWORD 'SuaSenha@123';
CREATE DATABASE service_orders_production OWNER deploy;
GRANT ALL PRIVILEGES ON DATABASE service_orders_production TO deploy;
\q
EOF
```

---

## 4️⃣ DEPLOY RAILS (15 min)

```bash
# Clonar
cd /home/deploy
git clone https://github.com/cmscheffer/my-orders.git
cd my-orders

# .env.production
cat > .env.production << 'EOF'
RAILS_ENV=production
DATABASE_URL=postgresql://deploy:SuaSenha@123@localhost/service_orders_production
SECRET_KEY_BASE=$(bundle exec rails secret)
RAILS_MASTER_KEY=$(cat config/master.key)
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
DEVISE_MAILER_HOST=seudominio.com
EOF

# Instalar gems
bundle config set --local deployment 'true'
bundle config set --local without 'development test'
bundle install

# Database
export $(cat .env.production | xargs)
bundle exec rails db:create RAILS_ENV=production
bundle exec rails db:migrate RAILS_ENV=production
bundle exec rails db:seed RAILS_ENV=production

# Assets
bundle exec rails assets:precompile RAILS_ENV=production

# Admin
bundle exec rails runner "User.create!(name: 'Admin', email: 'admin@admin.com', password: 'admin123', role: 'admin')" RAILS_ENV=production
```

---

## 5️⃣ IMPLEMENTAR NFE.IO (10 min)

```bash
cd /home/deploy/my-orders

# Adicionar gems
cat >> Gemfile << 'EOF'
gem 'httparty', '~> 0.21'
gem 'dotenv-rails', '~> 2.8'
EOF

bundle install

# Migration
rails g migration CreateInvoices
# Copiar código da migration do guia completo
bundle exec rails db:migrate RAILS_ENV=production

# Atualizar .env.production
nano .env.production
# Adicionar:
# NFEIO_API_KEY=sua_api_key
# NFEIO_COMPANY_ID=seu_company_id
# NFEIO_ENVIRONMENT=production
# NFEIO_WEBHOOK_SECRET=$(openssl rand -hex 32)

# Criar arquivos:
# - config/initializers/nfeio.rb
# - app/models/invoice.rb
# - app/services/nfeio_service.rb
# - app/controllers/invoices_controller.rb
# - app/controllers/webhooks_controller.rb
# - app/views/invoices/*
# (Copiar do GUIA_COMPLETO_DEPLOY_UBUNTU_24.04.md)

# Atualizar routes
# (Adicionar rotas do guia completo)
```

---

## 6️⃣ NGINX + PUMA (10 min)

```bash
# Instalar Nginx
sudo apt install -y nginx

# Configurar site
sudo tee /etc/nginx/sites-available/service-orders > /dev/null << 'EOF'
upstream puma {
  server unix:///home/deploy/my-orders/shared/sockets/puma.sock;
}

server {
  listen 80;
  server_name SEU_IP;
  root /home/deploy/my-orders/public;
  
  location ^~ /assets/ {
    gzip_static on;
    expires max;
  }
  
  try_files $uri/index.html $uri @puma;
  
  location @puma {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://puma;
  }
  
  client_max_body_size 10M;
}
EOF

# Ativar
sudo ln -s /etc/nginx/sites-available/service-orders /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx

# Configurar Puma
mkdir -p /home/deploy/my-orders/shared/sockets
mkdir -p /home/deploy/my-orders/log

# Criar serviço systemd
sudo tee /etc/systemd/system/puma.service > /dev/null << 'EOF'
[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
User=deploy
WorkingDirectory=/home/deploy/my-orders
EnvironmentFile=/home/deploy/my-orders/.env.production
ExecStart=/home/deploy/.rbenv/shims/bundle exec puma -C config/puma.rb
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Iniciar
sudo systemctl daemon-reload
sudo systemctl enable puma
sudo systemctl start puma
```

---

## 7️⃣ TESTES (5 min)

```bash
# Verificar serviços
sudo systemctl status puma
sudo systemctl status nginx
sudo systemctl status postgresql

# Acessar
# http://SEU_IP

# Login
# Email: admin@admin.com
# Senha: admin123

# Testar funcionalidades básicas
```

---

## ✅ CHECKLIST

- [ ] Servidor configurado
- [ ] Ruby 3.2.0 instalado
- [ ] PostgreSQL rodando
- [ ] Rails app clonado
- [ ] Gems instaladas
- [ ] Database migrado
- [ ] Assets compilados
- [ ] Admin criado
- [ ] NFE.io configurado
- [ ] Nginx rodando
- [ ] Puma rodando
- [ ] Site acessível
- [ ] Login funciona

---

## 🔧 COMANDOS ÚTEIS

```bash
# Logs
tail -f /home/deploy/my-orders/log/production.log
sudo journalctl -u puma -f

# Reiniciar
sudo systemctl restart puma
sudo systemctl restart nginx

# Deploy atualizado
cd /home/deploy/my-orders
git pull
bundle install
bundle exec rails db:migrate RAILS_ENV=production
bundle exec rails assets:precompile RAILS_ENV=production
sudo systemctl restart puma
```

---

## 🆘 TROUBLESHOOTING

### Erro: 502 Bad Gateway
```bash
sudo systemctl status puma
tail -f /home/deploy/my-orders/log/puma.stdout.log
```

### Erro: Assets não carregam
```bash
cd /home/deploy/my-orders
export $(cat .env.production | xargs)
bundle exec rails assets:clobber RAILS_ENV=production
bundle exec rails assets:precompile RAILS_ENV=production
sudo systemctl restart puma
```

### Erro: Database connection
```bash
psql -U deploy -d service_orders_production -h localhost -W
cat /home/deploy/my-orders/.env.production | grep DATABASE
```

---

## 📚 DOCUMENTAÇÃO COMPLETA

Para instruções detalhadas:
👉 **GUIA_COMPLETO_DEPLOY_UBUNTU_24.04.md**

---

## 🎉 PRONTO!

Seu sistema está no ar em: **http://SEU_IP**

**Próximos passos:**
1. Configurar domínio
2. Instalar SSL (Let's Encrypt)
3. Criar usuários
4. Emitir primeira nota fiscal
5. Configurar backups

---

*Deploy em produção em menos de 1 hora! 🚀*
