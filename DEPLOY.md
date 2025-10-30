# 🚢 Guia de Deploy - Sistema de Ordens de Serviço

Este guia detalha como fazer deploy do sistema em diferentes plataformas.

## 📋 Índice

- [Preparação](#preparação)
- [Heroku](#heroku)
- [Railway](#railway)
- [Render](#render)
- [Fly.io](#flyio)
- [VPS (DigitalOcean, AWS, etc)](#vps)
- [Configurações de Produção](#configurações-de-produção)

---

## 🔧 Preparação

Antes de fazer deploy, certifique-se de:

1. ✅ Código está funcionando localmente
2. ✅ Testes passando
3. ✅ Variáveis de ambiente configuradas
4. ✅ Database.yml configurado para produção
5. ✅ Secrets configurados

### Gerar Secret Key Base

```bash
rails secret
```

Copie o resultado e use como `SECRET_KEY_BASE` nas variáveis de ambiente.

---

## 🟣 Heroku

### Pré-requisitos
- Conta no Heroku
- Heroku CLI instalado

### Passo a Passo

```bash
# 1. Login no Heroku
heroku login

# 2. Criar aplicação
heroku create nome-do-seu-app

# 3. Adicionar PostgreSQL
heroku addons:create heroku-postgresql:essential-0

# 4. Configurar variáveis de ambiente
heroku config:set RAILS_ENV=production
heroku config:set RAILS_SERVE_STATIC_FILES=true
heroku config:set SECRET_KEY_BASE=$(rails secret)

# 5. Deploy
git push heroku main

# 6. Migrar banco de dados
heroku run rails db:migrate

# 7. Popular banco (opcional)
heroku run rails db:seed

# 8. Abrir aplicação
heroku open
```

### Procfile (criar na raiz)

```ruby
web: bundle exec puma -C config/puma.rb
release: rails db:migrate
```

### Resolver problemas

```bash
# Ver logs
heroku logs --tail

# Reiniciar
heroku restart

# Console Rails
heroku run rails console
```

---

## 🚂 Railway

### Pré-requisitos
- Conta no Railway
- Railway CLI (opcional)

### Via Interface Web

1. Acesse https://railway.app
2. Click em "New Project"
3. Selecione "Deploy from GitHub repo"
4. Conecte seu repositório
5. Railway detecta automaticamente Ruby/Rails
6. Configure variáveis:
   - `RAILS_ENV=production`
   - `SECRET_KEY_BASE=<seu-secret>`
7. Railway provisiona PostgreSQL automaticamente
8. Deploy acontece automaticamente

### Via CLI

```bash
# Instalar Railway CLI
npm install -g @railway/cli

# Login
railway login

# Criar projeto
railway init

# Adicionar PostgreSQL
railway add

# Deploy
railway up

# Ver logs
railway logs

# Abrir app
railway open
```

---

## 🎨 Render

### Pré-requisitos
- Conta no Render
- Repositório no GitHub

### Passo a Passo

1. **Criar Web Service**
   - Acesse https://render.com
   - Click em "New +" → "Web Service"
   - Conecte seu repositório GitHub

2. **Configurar Build**
   - **Name:** service-orders-app
   - **Environment:** Ruby
   - **Build Command:** `bundle install; rails db:migrate; rails assets:precompile`
   - **Start Command:** `bundle exec puma -C config/puma.rb`

3. **Criar Database**
   - Click em "New +" → "PostgreSQL"
   - Nome: service-orders-db
   - Copie a URL do banco

4. **Configurar Variáveis de Ambiente**
   ```
   RAILS_ENV=production
   RAILS_SERVE_STATIC_FILES=true
   SECRET_KEY_BASE=<seu-secret>
   DATABASE_URL=<url-do-banco>
   RAILS_MASTER_KEY=<seu-master-key>
   ```

5. **Deploy**
   - Render faz deploy automaticamente
   - Monitore os logs na interface

### render.yaml (opcional)

```yaml
services:
  - type: web
    name: service-orders-app
    env: ruby
    buildCommand: bundle install; rails db:migrate; rails assets:precompile
    startCommand: bundle exec puma -C config/puma.rb
    envVars:
      - key: RAILS_ENV
        value: production
      - key: SECRET_KEY_BASE
        generateValue: true
      - key: DATABASE_URL
        fromDatabase:
          name: service-orders-db
          property: connectionString

databases:
  - name: service-orders-db
    plan: starter
```

---

## 🪰 Fly.io

### Pré-requisitos
- Conta no Fly.io
- Flyctl instalado

```bash
# Instalar flyctl
curl -L https://fly.io/install.sh | sh
```

### Deploy

```bash
# Login
flyctl auth login

# Launch (primeiro deploy)
flyctl launch

# Escolha as opções:
# - App name: service-orders-app
# - Region: escolha a mais próxima
# - PostgreSQL: Yes
# - Redis: No (por enquanto)

# Deploy
flyctl deploy

# Ver status
flyctl status

# Ver logs
flyctl logs

# Abrir app
flyctl open

# Executar migrations
flyctl ssh console
rails db:migrate
```

### fly.toml

```toml
app = "service-orders-app"
primary_region = "gru"

[build]
  [build.args]
    BUNDLE_WITHOUT = "development:test"
    NODE_VERSION = "18.16.0"
    RAILS_ENV = "production"

[env]
  PORT = "8080"
  RAILS_ENV = "production"
  RAILS_SERVE_STATIC_FILES = "true"

[http_service]
  internal_port = 8080
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 0

[[statics]]
  guest_path = "/app/public"
  url_prefix = "/"
```

---

## 🖥️ VPS (DigitalOcean, AWS, Linode, etc)

### Pré-requisitos
- Servidor Ubuntu 22.04 ou superior
- Acesso SSH
- Domínio apontando para o servidor (opcional)

### Instalação Completa

```bash
# 1. Atualizar sistema
sudo apt update && sudo apt upgrade -y

# 2. Instalar dependências
sudo apt install -y curl gnupg2 git build-essential libssl-dev \
  libreadline-dev zlib1g-dev autoconf bison libyaml-dev \
  libncurses5-dev libffi-dev libgdbm-dev postgresql \
  postgresql-contrib libpq-dev nginx

# 3. Instalar rbenv e Ruby
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-installer | bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

rbenv install 3.2.0
rbenv global 3.2.0

# 4. Instalar Rails
gem install rails bundler

# 5. Configurar PostgreSQL
sudo -u postgres createuser -s deploy
sudo -u postgres psql -c "ALTER USER deploy WITH PASSWORD 'senha_forte';"
sudo -u postgres createdb service_orders_production -O deploy

# 6. Clonar projeto
cd /var/www
sudo git clone <seu-repositorio> service_orders_app
sudo chown -R $USER:$USER service_orders_app
cd service_orders_app

# 7. Instalar gems
bundle install --deployment --without development test

# 8. Configurar environment
nano .env
# Adicione:
# SECRET_KEY_BASE=<seu-secret>
# DATABASE_URL=postgresql://deploy:senha_forte@localhost/service_orders_production

# 9. Setup database
RAILS_ENV=production rails db:migrate
RAILS_ENV=production rails db:seed

# 10. Precompilar assets
RAILS_ENV=production rails assets:precompile

# 11. Configurar Puma como serviço
sudo nano /etc/systemd/system/puma.service
```

**Conteúdo do puma.service:**

```ini
[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
User=deploy
WorkingDirectory=/var/www/service_orders_app
Environment=RAILS_ENV=production
ExecStart=/home/deploy/.rbenv/shims/bundle exec puma -C config/puma.rb
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
# 12. Iniciar Puma
sudo systemctl daemon-reload
sudo systemctl enable puma
sudo systemctl start puma

# 13. Configurar Nginx
sudo nano /etc/nginx/sites-available/service_orders_app
```

**Conteúdo do Nginx config:**

```nginx
upstream puma {
  server unix:///var/www/service_orders_app/tmp/sockets/puma.sock;
}

server {
  listen 80;
  server_name seu-dominio.com;

  root /var/www/service_orders_app/public;

  try_files $uri/index.html $uri @puma;

  location @puma {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://puma;
  }

  error_page 500 502 503 504 /500.html;
  client_max_body_size 10M;
  keepalive_timeout 10;
}
```

```bash
# 14. Ativar site
sudo ln -s /etc/nginx/sites-available/service_orders_app /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# 15. Configurar SSL (opcional mas recomendado)
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d seu-dominio.com
```

---

## ⚙️ Configurações de Produção

### Database.yml

```yaml
production:
  <<: *default
  url: <%= ENV['DATABASE_URL'] %>
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
```

### Production.rb

```ruby
# config/environments/production.rb
Rails.application.configure do
  config.force_ssl = true
  config.log_level = :info
  config.assets.compile = false
  config.assets.js_compressor = :terser
  config.assets.css_compressor = :sass
  
  config.action_mailer.default_url_options = { 
    host: ENV['APP_HOST'] || 'seu-dominio.com' 
  }
end
```

### Variáveis de Ambiente Necessárias

```bash
# Essenciais
RAILS_ENV=production
SECRET_KEY_BASE=<gerado-com-rails-secret>
DATABASE_URL=postgresql://user:pass@host/database

# Opcionais
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
RAILS_MAX_THREADS=5
WEB_CONCURRENCY=2

# Email (se configurado)
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_DOMAIN=seu-dominio.com
SMTP_USERNAME=seu-email@gmail.com
SMTP_PASSWORD=sua-senha-app
```

---

## 🔒 Checklist de Segurança

- [ ] SECRET_KEY_BASE único e seguro
- [ ] Senhas de banco de dados fortes
- [ ] HTTPS/SSL configurado
- [ ] Variáveis de ambiente protegidas
- [ ] Firewall configurado
- [ ] Backups automáticos configurados
- [ ] Logs monitorados
- [ ] Atualizações de segurança automáticas
- [ ] Rate limiting configurado
- [ ] CORS configurado (se necessário)

---

## 📊 Monitoramento

### Logs

```bash
# Heroku
heroku logs --tail

# Railway
railway logs

# Render
# Via dashboard web

# VPS
sudo journalctl -u puma -f
sudo tail -f /var/log/nginx/access.log
```

### Performance

- Configure New Relic, DataDog ou Scout APM
- Monitore uso de memória e CPU
- Configure alertas para erros 500

---

## 🆘 Troubleshooting

### Assets não carregam

```bash
RAILS_ENV=production rails assets:precompile
```

### Database connection error

Verifique DATABASE_URL e permissões

### 502 Bad Gateway

Verifique se Puma está rodando:

```bash
sudo systemctl status puma
```

### Migrações não executaram

```bash
# Heroku
heroku run rails db:migrate

# VPS
RAILS_ENV=production rails db:migrate
```

---

## 📚 Recursos Adicionais

- [Heroku Ruby Support](https://devcenter.heroku.com/articles/ruby-support)
- [Railway Docs](https://docs.railway.app/)
- [Render Rails Guide](https://render.com/docs/deploy-rails)
- [Fly.io Rails](https://fly.io/docs/rails/)
- [DigitalOcean Rails](https://www.digitalocean.com/community/tutorials/how-to-deploy-a-rails-app-with-puma-and-nginx-on-ubuntu-22-04)

---

**Boa sorte com seu deploy! 🚀**
