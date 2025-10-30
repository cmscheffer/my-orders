# 🚀 Guia de Deploy para Produção (Heroku)

Este documento contém instruções detalhadas para fazer deploy da aplicação no Heroku com todas as configurações de segurança.

## 📋 Pré-requisitos

1. Conta no Heroku: https://signup.heroku.com
2. Heroku CLI instalado: https://devcenter.heroku.com/articles/heroku-cli
3. Git configurado
4. Gems instaladas: `bundle install`

## 🔐 Configuração de Credentials (Rails Encrypted Credentials)

### O que são Credentials?

As credentials do Rails são arquivos criptografados que armazenam informações sensíveis como:
- Chaves de API
- Senhas de banco de dados
- Tokens de serviços externos
- Secret keys

### Estrutura de Arquivos

- `config/master.key` - Chave mestra para descriptografar as credentials (NUNCA fazer commit!)
- `config/credentials.yml.enc` - Arquivo criptografado com as credentials (pode fazer commit)

### Como Editar as Credentials

```bash
# Editar credentials de produção
EDITOR="nano" rails credentials:edit --environment production

# Ou para credentials padrão (development)
EDITOR="nano" rails credentials:edit
```

### Exemplo de Estrutura de Credentials

```yaml
# config/credentials/production.yml.enc (após descriptografar)

# Secret key base (gerada automaticamente)
secret_key_base: abc123def456...

# Configurações de banco de dados (opcional no Heroku)
database:
  username: postgres_user
  password: senha_segura
  host: db.example.com

# API Keys de serviços externos (exemplo)
aws:
  access_key_id: AKIAIOSFODNN7EXAMPLE
  secret_access_key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
  region: us-east-1
  bucket: my-app-uploads

sendgrid:
  api_key: SG.xxxxx
  
# Outras configurações sensíveis
api_keys:
  stripe: sk_live_xxxxx
  google_maps: AIzaSyXXXXX
```

### Como Usar as Credentials no Código

```ruby
# Em qualquer lugar da aplicação
Rails.application.credentials.aws[:access_key_id]
Rails.application.credentials.sendgrid[:api_key]
Rails.application.credentials.dig(:api_keys, :stripe)
```

## 🏗️ Deploy no Heroku

### 1. Instalar Heroku CLI

```bash
# macOS
brew tap heroku/brew && brew install heroku

# Ubuntu/Debian
curl https://cli-assets.heroku.com/install-ubuntu.sh | sh

# Windows
# Baixar instalador em: https://devcenter.heroku.com/articles/heroku-cli
```

### 2. Login no Heroku

```bash
heroku login
```

### 3. Criar Aplicação no Heroku

```bash
# Criar app (o nome precisa ser único)
heroku create nome-do-seu-app

# Ou deixar o Heroku gerar um nome aleatório
heroku create
```

### 4. Adicionar PostgreSQL

```bash
# Adicionar PostgreSQL (plano gratuito hobby-dev)
heroku addons:create heroku-postgresql:essential-0

# Verificar que o DATABASE_URL foi configurado
heroku config:get DATABASE_URL
```

### 5. Configurar a Master Key

```bash
# Configurar a RAILS_MASTER_KEY no Heroku
# Esta chave está no arquivo config/master.key (NÃO fazer commit deste arquivo!)
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)

# Ou manualmente:
heroku config:set RAILS_MASTER_KEY=sua_master_key_aqui
```

### 6. Configurar Variáveis de Ambiente

```bash
# Configurar host da aplicação (para devise e URLs)
heroku config:set APP_HOST=nome-do-seu-app.herokuapp.com

# Configurar Rails env
heroku config:set RAILS_ENV=production
heroku config:set RACK_ENV=production

# Configurar secret key base (se não usar credentials)
heroku config:set SECRET_KEY_BASE=$(rails secret)

# Configurar log para STDOUT (Heroku requirement)
heroku config:set RAILS_LOG_TO_STDOUT=enabled
heroku config:set RAILS_SERVE_STATIC_FILES=enabled
```

### 7. Deploy da Aplicação

```bash
# Fazer commit de todas as mudanças
git add .
git commit -m "Configurar aplicação para produção no Heroku"

# Push para o Heroku
git push heroku main

# Ou se sua branch principal for master:
git push heroku master
```

### 8. Executar Migrations

```bash
# Rodar migrations no Heroku
heroku run rails db:migrate

# Ou usar o release phase (já configurado no Procfile)
# As migrations rodam automaticamente em cada deploy
```

### 9. Criar Usuário Admin Inicial

```bash
# Acessar console do Rails no Heroku
heroku run rails console

# No console, criar usuário admin:
User.create!(
  email: 'admin@exemplo.com',
  password: 'senha_segura_aqui',
  password_confirmation: 'senha_segura_aqui',
  role: 'admin'
)
```

### 10. Verificar Deploy

```bash
# Abrir aplicação no navegador
heroku open

# Ver logs em tempo real
heroku logs --tail

# Verificar status
heroku ps
```

## 🔒 Configurações de Segurança Implementadas

### ✅ SSL/HTTPS Forçado
- `config.force_ssl = true` em production.rb
- `config.assume_ssl = true` para reverse proxy
- Heroku fornece SSL automático em *.herokuapp.com

### ✅ Headers de Segurança (gem: secure_headers)
- **CSP** (Content Security Policy) - Previne XSS
- **HSTS** (HTTP Strict Transport Security) - Força HTTPS
- **X-Frame-Options** - Previne clickjacking
- **X-Content-Type-Options** - Previne MIME sniffing
- **X-XSS-Protection** - Proteção contra XSS
- **Referrer-Policy** - Controla informações de referência

### ✅ Proteção contra DDoS (gem: rack-attack)
- Limite de 300 requisições/minuto por IP
- Limite de 5 tentativas de login/20 segundos
- Bloqueio de User-Agents suspeitos
- Whitelist para localhost e IPs confiáveis

### ✅ Credentials Criptografadas
- Todas as informações sensíveis em `credentials.yml.enc`
- Master key nunca é commitada no git
- Credentials são criptografadas com AES-256-GCM

### ✅ PostgreSQL em Produção
- SQLite apenas em development/test
- PostgreSQL robusto para produção
- Configuração automática via DATABASE_URL

## 📊 Monitoramento e Logs

### Ver Logs

```bash
# Logs em tempo real
heroku logs --tail

# Últimas 200 linhas
heroku logs -n 200

# Filtrar por tipo
heroku logs --source app --tail
heroku logs --source heroku --tail
```

### Métricas

```bash
# Ver métricas da aplicação
heroku metrics

# Acessar dashboard no navegador
heroku dashboard
```

### Performance Monitoring

Recomendado adicionar addons:
```bash
# New Relic (monitoramento de performance)
heroku addons:create newrelic:wayne

# Papertrail (agregação de logs)
heroku addons:create papertrail:choklad

# Sentry (tracking de erros)
heroku addons:create sentry:f1
```

## 🔄 Atualizações e Manutenção

### Deploy de Atualizações

```bash
git add .
git commit -m "Descrição das mudanças"
git push heroku main
```

### Rollback (Reverter Deploy)

```bash
# Ver releases anteriores
heroku releases

# Fazer rollback para versão anterior
heroku rollback
```

### Backup do Banco de Dados

```bash
# Criar backup manual
heroku pg:backups:capture

# Listar backups
heroku pg:backups

# Download de backup
heroku pg:backups:download
```

### Escalar Aplicação

```bash
# Ver dynos atuais
heroku ps

# Escalar web dynos
heroku ps:scale web=2

# Mudar tipo de dyno (requer plano pago)
heroku ps:type web=standard-1x
```

## 🆘 Troubleshooting

### Erro: "Push rejected, failed to compile Ruby app"

```bash
# Verificar versão do Ruby no Gemfile
# Certificar que bundle install foi executado
bundle install
git add Gemfile.lock
git commit -m "Update Gemfile.lock"
git push heroku main
```

### Erro: "ActiveRecord::NoDatabaseError"

```bash
# Criar banco de dados
heroku run rails db:create

# Rodar migrations
heroku run rails db:migrate
```

### Erro: "Missing encryption key"

```bash
# Configurar RAILS_MASTER_KEY
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)
```

### Erro: "No such app"

```bash
# Adicionar remote do Heroku
heroku git:remote -a nome-do-seu-app
```

## 🔗 Links Úteis

- **Heroku Dev Center**: https://devcenter.heroku.com/
- **Rails on Heroku**: https://devcenter.heroku.com/articles/getting-started-with-rails7
- **Heroku Postgres**: https://devcenter.heroku.com/articles/heroku-postgresql
- **Rails Credentials**: https://guides.rubyonrails.org/security.html#custom-credentials

## 📝 Checklist de Deploy

- [ ] Bundle install executado
- [ ] Credentials configuradas
- [ ] Master key adicionada ao Heroku
- [ ] PostgreSQL addon adicionado
- [ ] Variáveis de ambiente configuradas
- [ ] Código commitado no Git
- [ ] Push para Heroku realizado
- [ ] Migrations executadas
- [ ] Usuário admin criado
- [ ] Aplicação testada no navegador
- [ ] SSL/HTTPS verificado
- [ ] Logs monitorados

## 🎉 Pronto!

Sua aplicação está agora rodando em produção com todas as configurações de segurança!

Para acessar: `heroku open`
