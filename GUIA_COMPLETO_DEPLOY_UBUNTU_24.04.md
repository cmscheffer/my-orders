# 🚀 GUIA COMPLETO DE DEPLOY - Ubuntu Server 24.04
## Sistema de Ordens de Serviço + NFE.io

---

## 📋 ÍNDICE RÁPIDO

1. [Visão Geral](#1-visão-geral)
2. [Requisitos e Custos](#2-requisitos-e-custos)
3. [Preparação Inicial](#3-preparação-inicial)
4. [Configuração do Servidor](#4-configuração-do-servidor)
5. [Instalação de Dependências](#5-instalação-de-dependências)
6. [Configuração do PostgreSQL](#6-configuração-do-postgresql)
7. [Deploy da Aplicação Rails](#7-deploy-da-aplicação-rails)
8. [Implementação NFE.io](#8-implementação-nfeio)
9. [Configuração Nginx + SSL](#9-configuração-nginx--ssl)
10. [Automação com Systemd](#10-automação-com-systemd)
11. [Testes e Validação](#11-testes-e-validação)
12. [Manutenção e Monitoramento](#12-manutenção-e-monitoramento)
13. [Troubleshooting](#13-troubleshooting)
14. [Checklist Final](#14-checklist-final)

---

## 1. VISÃO GERAL

### 🎯 O que será implementado

Este guia implementa um sistema completo de produção contendo:

✅ **Sistema Base:**
- Ruby on Rails 7.1
- PostgreSQL (banco de dados)
- Nginx (servidor web)
- Puma (app server)
- SSL/HTTPS (Let's Encrypt)
- Systemd (gerenciamento de serviços)

✅ **Funcionalidades:**
- Autenticação (Devise)
- Gestão de Ordens de Serviço
- Dashboard com métricas
- Gestão de clientes, peças, técnicos
- Relatórios e exportação
- **Emissão de NFS-e oficial (NFE.io)**

✅ **Segurança:**
- Firewall configurado
- SSL/TLS
- Variáveis de ambiente
- Rate limiting
- Backups automáticos

### ⏱️ Tempo estimado

| Etapa | Tempo |
|-------|-------|
| Criar servidor e configuração inicial | 30 min |
| Instalar dependências | 20 min |
| Configurar PostgreSQL | 10 min |
| Deploy aplicação Rails | 30 min |
| Implementar NFE.io | 2-3 horas |
| Nginx + SSL | 20 min |
| Testes | 30 min |
| **TOTAL** | **4-5 horas** |

---

## 2. REQUISITOS E CUSTOS

### 💰 Custos Mensais Estimados

| Item | Custo |
|------|-------|
| **VPS Vultr** (2GB RAM) | $12/mês (~R$ 60) |
| **NFE.io** (Starter - 100 notas/mês) | R$ 20/mês |
| **Certificado Digital e-CNPJ A1** | R$ 150-300/ano (~R$ 15-25/mês) |
| **Backups automáticos** (opcional) | $1.20/mês (~R$ 6) |
| **TOTAL MENSAL** | **~R$ 100-110** |
| **TOTAL ANUAL** | **~R$ 1.200-1.300** |

### 📦 Pré-requisitos

**Contas e serviços:**
- [ ] Conta na Vultr (https://www.vultr.com)
- [ ] Conta no GitHub (código do projeto)
- [ ] Conta no NFE.io (https://nfe.io)
- [ ] Certificado Digital e-CNPJ A1 (emitido por AC autorizada)
- [ ] Domínio próprio (opcional, mas recomendado)

**No seu computador local:**
- [ ] Cliente SSH (Terminal Linux/Mac, PuTTY Windows)
- [ ] Git configurado
- [ ] Editor de texto (VS Code, Sublime, etc)

**Dados necessários:**
- [ ] CNPJ da empresa
- [ ] Inscrição Municipal
- [ ] Razão Social
- [ ] Endereço completo
- [ ] Códigos de serviço (CNAE)

---

## 3. PREPARAÇÃO INICIAL

### 📝 Etapa 3.1: Criar Servidor na Vultr

**Passo 1:** Acessar Vultr
```
1. Acesse: https://my.vultr.com
2. Clique: "Deploy New Server"
```

**Passo 2:** Configurar servidor
```
Server Type: Cloud Compute - Shared CPU
Location: São Paulo, Brasil (melhor latência)
Image: Ubuntu 24.04 LTS x64 ✅
Server Size: $12/mês (2GB RAM, 55GB SSD) ✅

Additional Features:
  ✅ Enable IPv6
  ✅ Enable Auto Backups ($1.20/mo)

Server Hostname: service-orders-prod
Server Label: Sistema de Ordens - Produção
```

**Passo 3:** Deploy e aguardar
```
1. Clique: "Deploy Now"
2. Aguarde: 2-5 minutos
3. Copie o IP do servidor (ex: 123.45.67.89)
4. Copie a senha root do painel Vultr
```

### 🔑 Etapa 3.2: Primeira Conexão SSH

```bash
# Conectar ao servidor
ssh root@SEU_IP_AQUI

# Exemplo:
ssh root@123.45.67.89

# Cole a senha copiada do painel Vultr
# Recomendado: mudar senha na primeira conexão
passwd
```

---

## 4. CONFIGURAÇÃO DO SERVIDOR

### 🔒 Etapa 4.1: Atualizar Sistema

```bash
# Atualizar lista de pacotes
apt update

# Atualizar todos os pacotes
apt upgrade -y

# Instalar utilitários essenciais
apt install -y curl wget git build-essential \
  software-properties-common ufw htop
```

### 👤 Etapa 4.2: Criar Usuário Deploy

**Por que?** Rodar aplicações como root é inseguro. Vamos criar um usuário dedicado.

```bash
# Criar usuário deploy
adduser deploy
# Digite uma senha FORTE quando solicitado
# Confirme os dados (pode deixar em branco)

# Adicionar ao grupo sudo (para comandos administrativos)
usermod -aG sudo deploy

# Testar acesso
su - deploy

# Testar sudo
sudo ls
# Digite a senha do usuário deploy

# Voltar para root
exit
```

### 🔐 Etapa 4.3: Configurar SSH para Deploy

```bash
# Como usuário root, criar diretório SSH para deploy
mkdir -p /home/deploy/.ssh
chmod 700 /home/deploy/.ssh

# Copiar chaves SSH autorizadas (se houver)
cp /root/.ssh/authorized_keys /home/deploy/.ssh/ 2>/dev/null || true
chown -R deploy:deploy /home/deploy/.ssh
chmod 600 /home/deploy/.ssh/authorized_keys 2>/dev/null || true

# Agora você pode conectar direto com usuário deploy
# ssh deploy@SEU_IP
```

### 🛡️ Etapa 4.4: Configurar Firewall

```bash
# Permitir SSH (IMPORTANTE: fazer antes de ativar!)
ufw allow OpenSSH
ufw allow 22/tcp

# Permitir HTTP e HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Ativar firewall
ufw enable

# Verificar status
ufw status verbose

# Deve mostrar:
# Status: active
# To                         Action      From
# --                         ------      ----
# 22/tcp                     ALLOW       Anywhere
# 80/tcp                     ALLOW       Anywhere
# 443/tcp                    ALLOW       Anywhere
```

**⚠️ IMPORTANTE:** Se perder conexão SSH após ativar firewall, acesse o console web da Vultr!

---

## 5. INSTALAÇÃO DE DEPENDÊNCIAS

### 💎 Etapa 5.1: Instalar Ruby via rbenv

**Conectar como usuário deploy:**
```bash
# Se ainda estiver como root:
su - deploy
cd ~
```

**Instalar dependências do Ruby:**
```bash
sudo apt install -y git curl libssl-dev libreadline-dev \
  zlib1g-dev autoconf bison build-essential libyaml-dev \
  libreadline-dev libncurses5-dev libffi-dev libgdbm-dev
```

**Instalar rbenv:**
```bash
# Baixar e instalar rbenv
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-installer | bash

# Adicionar ao PATH
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc

# Recarregar shell
source ~/.bashrc

# Verificar instalação
rbenv --version
# Deve mostrar: rbenv 1.x.x
```

**Instalar Ruby 3.2.0:**
```bash
# Instalar Ruby (demora ~10 minutos)
rbenv install 3.2.0

# Definir como versão global
rbenv global 3.2.0

# Verificar
ruby -v
# Deve mostrar: ruby 3.2.0pXXX

which ruby
# Deve mostrar: /home/deploy/.rbenv/shims/ruby
```

### 💎 Etapa 5.2: Instalar Bundler

```bash
gem install bundler

bundler --version
# Deve mostrar: Bundler version 2.x.x
```

### 💎 Etapa 5.3: Instalar Rails

```bash
gem install rails -v 7.1.6

rails --version
# Deve mostrar: Rails 7.1.6
```

### 📦 Etapa 5.4: Instalar Node.js

```bash
# Adicionar repositório NodeSource (Node.js 18 LTS)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -

# Instalar Node.js
sudo apt install -y nodejs

# Verificar
node -v
# Deve mostrar: v18.x.x

npm -v
# Deve mostrar: 9.x.x ou superior
```

### 📦 Etapa 5.5: Instalar Yarn

```bash
# Adicionar repositório Yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# Atualizar e instalar
sudo apt update
sudo apt install -y yarn

# Verificar
yarn --version
# Deve mostrar: 1.x.x
```

---

## 6. CONFIGURAÇÃO DO POSTGRESQL

### 🗄️ Etapa 6.1: Instalar PostgreSQL

```bash
# Instalar PostgreSQL e extensões
sudo apt install -y postgresql postgresql-contrib libpq-dev

# Iniciar serviço
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Verificar status
sudo systemctl status postgresql
# Deve mostrar: active (running)
```

### 🗄️ Etapa 6.2: Criar Banco e Usuário

```bash
# Conectar como usuário postgres
sudo -u postgres psql
```

**No prompt do PostgreSQL (`postgres=#`), execute:**

```sql
-- Criar usuário deploy
CREATE USER deploy WITH PASSWORD 'SenhaSegura@2024!Deploy';

-- Criar banco de dados
CREATE DATABASE service_orders_production OWNER deploy;

-- Dar permissões
GRANT ALL PRIVILEGES ON DATABASE service_orders_production TO deploy;

-- Criar extensões (se necessário)
\c service_orders_production
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Sair
\q
```

### 🗄️ Etapa 6.3: Testar Conexão

```bash
# Testar conexão com banco
psql -U deploy -d service_orders_production -h localhost -W

# Digite a senha: SenhaSegura@2024!Deploy

# Se conectar com sucesso, você verá:
# service_orders_production=>

# Testar comando
\dt
# Deve mostrar: Nenhuma relação encontrada (normal, banco vazio)

# Sair
\q
```

**✅ PostgreSQL configurado com sucesso!**

---

## 7. DEPLOY DA APLICAÇÃO RAILS

### 📂 Etapa 7.1: Clonar Repositório

```bash
# Como usuário deploy
cd /home/deploy

# Clonar projeto
git clone https://github.com/cmscheffer/my-orders.git

# Entrar na pasta
cd my-orders

# Verificar branch
git branch
# Deve mostrar: * main

# Verificar arquivos
ls -la
```

### ⚙️ Etapa 7.2: Configurar Variáveis de Ambiente

```bash
# Criar arquivo .env.production
nano .env.production
```

**Cole o conteúdo abaixo (ajuste os valores):**

```bash
# Ambiente
RAILS_ENV=production
RACK_ENV=production

# Database
DATABASE_URL=postgresql://deploy:SenhaSegura@2024!Deploy@localhost/service_orders_production

# Segurança (gerar com: bundle exec rails secret)
SECRET_KEY_BASE=COLE_AQUI_SECRET_GERADO_PASSO_7.3
RAILS_MASTER_KEY=COLE_AQUI_MASTER_KEY_PASSO_7.4

# Host
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true

# Devise (substitua pelo seu domínio)
DEVISE_MAILER_HOST=seudominio.com

# NFE.io (deixar vazio por enquanto - configurar depois)
NFEIO_API_KEY=
NFEIO_COMPANY_ID=
NFEIO_ENVIRONMENT=production
NFEIO_WEBHOOK_SECRET=
```

**Salvar:** `Ctrl + O` → `Enter` → `Ctrl + X`

**Proteger arquivo:**
```bash
chmod 600 .env.production
```

### 🔐 Etapa 7.3: Gerar SECRET_KEY_BASE

```bash
cd /home/deploy/my-orders

# Instalar gems primeiro
bundle config set --local deployment 'false'
bundle config set --local without 'development test'
bundle install

# Gerar secret
bundle exec rails secret

# Copie o output (uma string longa tipo: a1b2c3d4...)
# Cole no .env.production na linha SECRET_KEY_BASE=
```

**Editar .env.production:**
```bash
nano .env.production

# Encontre a linha:
SECRET_KEY_BASE=

# Cole o valor gerado:
SECRET_KEY_BASE=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6...
```

### 🔐 Etapa 7.4: Configurar RAILS_MASTER_KEY

**Opção A - Se você tem o arquivo `config/master.key` no Git:**
```bash
# O arquivo já está lá, copiar valor
cat config/master.key

# Copie o conteúdo e cole no .env.production
nano .env.production
# Adicione: RAILS_MASTER_KEY=valor_copiado
```

**Opção B - Gerar novo (SE NÃO TIVER):**
```bash
# Remover credentials antigos
rm -f config/credentials.yml.enc

# Gerar novos
EDITOR="nano" bundle exec rails credentials:edit

# Cole a SECRET_KEY_BASE gerada no passo 7.3:
# secret_key_base: a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6...

# Salvar: Ctrl+O, Enter, Ctrl+X

# Agora copiar a master key
cat config/master.key

# Adicionar ao .env.production
nano .env.production
# RAILS_MASTER_KEY=valor_da_master_key
```

### 📦 Etapa 7.5: Instalar Gems de Produção

```bash
cd /home/deploy/my-orders

bundle config set --local deployment 'true'
bundle config set --local without 'development test'
bundle install --jobs=4

# Verificar
bundle check
# Deve mostrar: The Gemfile's dependencies are satisfied
```

### 🗄️ Etapa 7.6: Preparar Banco de Dados

```bash
# Carregar variáveis de ambiente
export $(cat .env.production | xargs)

# Criar banco (se não existir)
bundle exec rails db:create RAILS_ENV=production

# Executar migrations
bundle exec rails db:migrate RAILS_ENV=production

# Popular com dados iniciais
bundle exec rails db:seed RAILS_ENV=production
```

**Verificar:**
```bash
# Ver tabelas criadas
psql -U deploy -d service_orders_production -h localhost -W

# No psql:
\dt
# Deve listar: users, service_orders, parts, technicians, etc

\q
```

### 🎨 Etapa 7.7: Compilar Assets

```bash
cd /home/deploy/my-orders

export $(cat .env.production | xargs)

# Compilar assets
bundle exec rails assets:precompile RAILS_ENV=production

# Verificar
ls -la public/assets/
# Deve mostrar vários arquivos .css, .js, imagens
```

### 👤 Etapa 7.8: Criar Usuário Admin

```bash
bundle exec rails console production
```

**No console Rails:**
```ruby
User.create!(
  name: 'Administrador',
  email: 'admin@seudominio.com',
  password: 'Admin@123!Segura',
  password_confirmation: 'Admin@123!Segura',
  role: 'admin'
)

# Verificar
User.count
# Deve mostrar: 1 (ou mais se tiver seeds)

User.last
# Deve mostrar o admin criado

exit
```

**✅ Aplicação Rails configurada!**

---

## 8. IMPLEMENTAÇÃO NFE.IO

### 📋 Etapa 8.1: Cadastrar no NFE.io

**Passo 1:** Criar conta
```
1. Acesse: https://nfe.io
2. Clique: "Experimente Grátis"
3. Preencha dados da empresa
```

**Passo 2:** Configurar empresa no dashboard
```
1. Login em: https://app.nfe.io
2. Vá em: Configurações → Empresa
3. Preencha todos os dados:
   - Razão Social
   - CNPJ
   - Inscrição Municipal
   - Endereço completo
   - Telefone e Email
```

**Passo 3:** Upload do Certificado Digital
```
1. Vá em: Configurações → Certificado Digital
2. Upload do arquivo .pfx (certificado e-CNPJ A1)
3. Digite a senha do certificado
4. Teste: botão "Testar Certificado"
```

**Passo 4:** Configurar impostos
```
1. Vá em: Configurações → Tributação
2. Configure:
   - Regime tributário (Simples, Lucro Presumido, etc)
   - Códigos de serviço (CNAE)
   - Alíquotas padrão (ISS, PIS, COFINS)
```

**Passo 5:** Obter credenciais de API
```
1. Vá em: Configurações → Integrações → API
2. Copie:
   - API Key (ex: sk_live_abc123...)
   - Company ID (ex: comp_abc123...)
```

### 📦 Etapa 8.2: Adicionar Gems NFE.io

```bash
cd /home/deploy/my-orders

# Editar Gemfile
nano Gemfile
```

**Adicionar no final do arquivo:**
```ruby
# NFE.io Integration
gem 'httparty', '~> 0.21'    # HTTP client
gem 'dotenv-rails', '~> 2.8' # Environment variables
```

**Instalar:**
```bash
bundle install
```

### 🗄️ Etapa 8.3: Criar Migration de Invoices

```bash
bundle exec rails generate migration CreateInvoices
```

**Editar migration** (`db/migrate/XXXXXXXXX_create_invoices.rb`):
```bash
nano db/migrate/$(ls -t db/migrate/ | head -1)
```

**Cole o conteúdo:**
```ruby
class CreateInvoices < ActiveRecord::Migration[7.1]
  def change
    create_table :invoices do |t|
      # Relacionamento
      t.references :service_order, null: false, foreign_key: true
      
      # Identificação
      t.string :invoice_number, null: false
      t.string :serie, default: "001"
      t.datetime :issued_at
      t.datetime :cancelled_at
      t.integer :status, default: 0
      
      # Valores
      t.decimal :service_value, precision: 10, scale: 2
      t.decimal :total_value, precision: 10, scale: 2
      
      # Impostos
      t.decimal :iss_rate, precision: 5, scale: 2, default: 5.00
      t.decimal :iss_value, precision: 10, scale: 2
      t.decimal :pis_value, precision: 10, scale: 2
      t.decimal :cofins_value, precision: 10, scale: 2
      t.decimal :net_value, precision: 10, scale: 2
      
      # Cliente
      t.string :customer_name
      t.string :customer_cpf_cnpj
      t.string :customer_email
      t.string :customer_address
      t.string :customer_city
      t.string :customer_state
      t.string :customer_zip_code
      
      # NFE.io
      t.string :nfeio_id
      t.string :nfeio_status
      t.string :official_number
      t.string :verification_code
      t.string :pdf_url
      t.text :nfeio_response
      t.text :error_message
      t.text :notes
      
      t.timestamps
    end
    
    add_index :invoices, :invoice_number, unique: true
    add_index :invoices, :status
    add_index :invoices, :nfeio_id
  end
end
```

**Executar migration:**
```bash
export $(cat .env.production | xargs)
bundle exec rails db:migrate RAILS_ENV=production
```

### ⚙️ Etapa 8.4: Atualizar .env.production com NFE.io

```bash
nano .env.production
```

**Atualizar as linhas NFE.io:**
```bash
# NFE.io
NFEIO_API_KEY=sk_live_abc123def456_COLE_SUA_API_KEY_AQUI
NFEIO_COMPANY_ID=comp_abc123def456_COLE_SEU_COMPANY_ID_AQUI
NFEIO_ENVIRONMENT=production
NFEIO_WEBHOOK_SECRET=$(openssl rand -hex 32)
```

**Gerar webhook secret:**
```bash
# Gerar secret
openssl rand -hex 32

# Copiar output e colar no .env.production
```

### 🔧 Etapa 8.5: Criar Initializer NFE.io

```bash
nano config/initializers/nfeio.rb
```

**Cole:**
```ruby
NFEIO_CONFIG = {
  api_key: ENV['NFEIO_API_KEY'],
  company_id: ENV['NFEIO_COMPANY_ID'],
  environment: ENV['NFEIO_ENVIRONMENT'] || 'production',
  webhook_secret: ENV['NFEIO_WEBHOOK_SECRET'],
  api_url: 'https://api.nfe.io/v1'
}.freeze

if Rails.env.production?
  raise "NFE.io API Key não configurada!" if NFEIO_CONFIG[:api_key].blank?
  raise "NFE.io Company ID não configurado!" if NFEIO_CONFIG[:company_id].blank?
end
```

### 📝 Etapa 8.6: Criar Model Invoice

```bash
nano app/models/invoice.rb
```

**Cole o código completo do invoice.rb** (disponível em `IMPLEMENTACAO_NFEIO.md` linhas 236-398)

*Nota: Por questões de espaço, consulte o arquivo IMPLEMENTACAO_NFEIO.md para o código completo*

### 🔌 Etapa 8.7: Criar Service NFE.io

```bash
mkdir -p app/services
nano app/services/nfeio_service.rb
```

**Cole o código completo** (disponível em `IMPLEMENTACAO_NFEIO.md` linhas 407-556)

### 🎮 Etapa 8.8: Criar Controller Invoices

```bash
nano app/controllers/invoices_controller.rb
```

**Cole o código completo** (disponível em `IMPLEMENTACAO_NFEIO.md` linhas 565-715)

### 🎮 Etapa 8.9: Criar Controller Webhooks

```bash
nano app/controllers/webhooks_controller.rb
```

**Cole:**
```ruby
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!
  
  def nfeio
    # Verificar signature
    signature = request.headers['X-NFE-Signature']
    
    unless valid_signature?(request.body.read, signature)
      render json: { error: 'Invalid signature' }, status: :unauthorized
      return
    end
    
    # Processar webhook
    data = JSON.parse(request.body.read)
    invoice = Invoice.find_by(nfeio_id: data['id'])
    
    if invoice
      invoice.update(
        nfeio_status: data['status'],
        official_number: data['number'],
        verification_code: data['verificationCode'],
        pdf_url: data['pdfUrl'],
        status: map_status(data['status'])
      )
    end
    
    render json: { success: true }, status: :ok
  rescue => e
    Rails.logger.error "Webhook error: #{e.message}"
    render json: { error: e.message }, status: :unprocessable_entity
  end
  
  private
  
  def valid_signature?(body, signature)
    expected = OpenSSL::HMAC.hexdigest(
      'SHA256',
      ENV['NFEIO_WEBHOOK_SECRET'],
      body
    )
    
    Rack::Utils.secure_compare(expected, signature)
  end
  
  def map_status(nfeio_status)
    case nfeio_status
    when 'Issued' then 'issued'
    when 'Cancelled' then 'cancelled'
    when 'Error' then 'error'
    else 'processing'
    end
  end
end
```

### 🛣️ Etapa 8.10: Atualizar Routes

```bash
nano config/routes.rb
```

**Adicionar (antes do `end` final):**
```ruby
  # Invoices
  resources :invoices, only: [:index, :show, :edit, :update] do
    member do
      post :issue
      delete :cancel
      get :download_pdf
    end
  end
  
  resources :service_orders do
    resources :invoices, only: [:new, :create]
  end
  
  # Webhooks
  post '/webhooks/nfeio', to: 'webhooks#nfeio'
```

### 📝 Etapa 8.11: Atualizar ServiceOrder Model

```bash
nano app/models/service_order.rb
```

**Adicionar no início (após belongs_to :user):**
```ruby
  has_one :invoice, dependent: :destroy
  
  def can_generate_invoice?
    completed? && total_value.present? && total_value > 0 && invoice.nil?
  end
```

### 🎨 Etapa 8.12: Criar Views

**Estrutura de pastas:**
```bash
mkdir -p app/views/invoices
```

**Arquivos a criar:**
```bash
# Index
nano app/views/invoices/index.html.erb

# Show
nano app/views/invoices/show.html.erb

# New
nano app/views/invoices/new.html.erb

# Edit
nano app/views/invoices/edit.html.erb

# Form parcial
nano app/views/invoices/_form.html.erb
```

*Nota: Códigos completos disponíveis em `IMPLEMENTACAO_NFEIO_PARTE2.md`*

### 🌍 Etapa 8.13: Adicionar Traduções PT-BR

```bash
nano config/locales/pt-BR.yml
```

**Adicionar:**
```yaml
pt-BR:
  activerecord:
    models:
      invoice: "Nota Fiscal"
    attributes:
      invoice:
        invoice_number: "Número"
        serie: "Série"
        status: "Status"
        issued_at: "Emitida em"
        total_value: "Valor Total"
        customer_name: "Cliente"
        official_number: "Nº Oficial"
        
  invoices:
    statuses:
      draft: "Rascunho"
      processing: "Processando"
      issued: "Emitida"
      error: "Erro"
      cancelled: "Cancelada"
```

### ✅ Etapa 8.14: Testar Integração NFE.io

```bash
# Recarregar variáveis
export $(cat .env.production | xargs)

# Testar no console
bundle exec rails console production
```

**No console:**
```ruby
# Verificar configuração
NFEIO_CONFIG
# Deve mostrar as configs

# Criar serviço de teste
service = NfeioService.new
# Não deve dar erro

# Se der erro, verificar API Key e Company ID
exit
```

**✅ NFE.io implementado!**

---

## 9. CONFIGURAÇÃO NGINX + SSL

### 🌐 Etapa 9.1: Instalar Nginx

```bash
sudo apt install -y nginx

sudo systemctl start nginx
sudo systemctl enable nginx

# Verificar
sudo systemctl status nginx
# Deve mostrar: active (running)

# Testar no navegador
# http://SEU_IP
# Deve mostrar: Welcome to nginx!
```

### 🌐 Etapa 9.2: Configurar Site

```bash
sudo nano /etc/nginx/sites-available/service-orders
```

**Cole (ajuste o domínio/IP):**
```nginx
upstream puma {
  server unix:///home/deploy/my-orders/shared/sockets/puma.sock;
}

server {
  listen 80;
  listen [::]:80;
  
  # Substitua pelo seu domínio OU use o IP
  server_name seudominio.com www.seudominio.com;
  # server_name 123.45.67.89;
  
  root /home/deploy/my-orders/public;
  
  access_log /var/log/nginx/service_orders_access.log;
  error_log /var/log/nginx/service_orders_error.log info;
  
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

**Ativar site:**
```bash
# Criar link simbólico
sudo ln -s /etc/nginx/sites-available/service-orders /etc/nginx/sites-enabled/

# Remover site padrão
sudo rm /etc/nginx/sites-enabled/default

# Testar configuração
sudo nginx -t
# Deve mostrar: syntax is ok, test is successful

# Reiniciar
sudo systemctl restart nginx
```

### 🔒 Etapa 9.3: Configurar SSL (Let's Encrypt)

**⚠️ IMPORTANTE:** Só funciona com domínio próprio. Pule esta etapa se usar apenas IP.

```bash
# Instalar Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obter certificado (substitua pelo seu domínio)
sudo certbot --nginx -d seudominio.com -d www.seudominio.com

# Siga as instruções:
# 1. Digite seu email
# 2. Aceite os termos (Y)
# 3. Compartilhar email? (opcional - N ou Y)
# 4. Redirecionar HTTP para HTTPS? (recomendado - escolha 2)

# Testar renovação automática
sudo certbot renew --dry-run
# Deve mostrar: Congratulations, all renewals succeeded
```

**Atualizar .env.production:**
```bash
nano /home/deploy/my-orders/.env.production

# Alterar:
DEVISE_MAILER_HOST=seudominio.com
```

**✅ SSL configurado!**

---

## 10. AUTOMAÇÃO COM SYSTEMD

### 🤖 Etapa 10.1: Configurar Puma

```bash
nano /home/deploy/my-orders/config/puma.rb
```

**Substituir conteúdo:**
```ruby
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

port ENV.fetch("PORT") { 3000 }

environment ENV.fetch("RAILS_ENV") { "development" }

pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

workers ENV.fetch("WEB_CONCURRENCY") { 2 }

preload_app!

plugin :tmp_restart

# Socket Unix para produção
if ENV["RAILS_ENV"] == "production"
  bind "unix:///home/deploy/my-orders/shared/sockets/puma.sock"
else
  bind "tcp://0.0.0.0:3000"
end

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

before_fork do
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
end
```

### 🤖 Etapa 10.2: Criar Diretórios

```bash
mkdir -p /home/deploy/my-orders/shared/sockets
mkdir -p /home/deploy/my-orders/log
mkdir -p /home/deploy/my-orders/tmp/pids
```

### 🤖 Etapa 10.3: Criar Serviço Systemd

```bash
sudo nano /etc/systemd/system/puma-service-orders.service
```

**Cole:**
```ini
[Unit]
Description=Puma HTTP Server - Service Orders
After=network.target postgresql.service

[Service]
Type=simple
User=deploy
Group=deploy
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

### 🤖 Etapa 10.4: Ativar e Iniciar

```bash
# Recarregar systemd
sudo systemctl daemon-reload

# Ativar (iniciar automaticamente no boot)
sudo systemctl enable puma-service-orders

# Iniciar
sudo systemctl start puma-service-orders

# Verificar status
sudo systemctl status puma-service-orders
# Deve mostrar: active (running)

# Ver logs
sudo journalctl -u puma-service-orders -f
# Ctrl+C para sair
```

**Comandos úteis:**
```bash
# Reiniciar
sudo systemctl restart puma-service-orders

# Parar
sudo systemctl stop puma-service-orders

# Ver logs
tail -f /home/deploy/my-orders/log/puma.stdout.log
tail -f /home/deploy/my-orders/log/production.log
```

**✅ Puma rodando como serviço!**

---

## 11. TESTES E VALIDAÇÃO

### ✅ Etapa 11.1: Testar Aplicação

**No navegador:**
```
1. Acesse: http://SEU_IP (ou https://seudominio.com)
2. Deve carregar a tela de login
3. Login: admin@seudominio.com
4. Senha: Admin@123!Segura
```

**Testes básicos:**
- [ ] Login funciona
- [ ] Dashboard carrega
- [ ] Criar ordem de serviço
- [ ] Criar cliente
- [ ] Criar técnico
- [ ] Criar peça
- [ ] Completar ordem de serviço
- [ ] Ver relatórios

### ✅ Etapa 11.2: Testar NFE.io

**Criar nota de teste:**
```
1. Complete uma ordem de serviço
2. Na tela da OS, clique "Emitir NFS-e"
3. Preencha dados do cliente:
   - Nome
   - CPF/CNPJ
   - Email
   - Endereço
4. Clique "Criar Nota Fiscal"
5. Na tela da nota, clique "Emitir"
6. Aguarde processamento (~10 segundos)
7. Deve mostrar: "✅ NFS-e emitida com sucesso!"
8. Verificar:
   - Número oficial preenchido
   - Código de verificação
   - Link PDF disponível
9. Clicar "Baixar PDF" e verificar documento oficial
```

**No dashboard NFE.io:**
```
1. Acesse: https://app.nfe.io
2. Vá em: Notas Fiscais
3. Deve aparecer a nota criada
4. Status: Emitida
```

### ✅ Etapa 11.3: Testar Webhook

```bash
# Ver logs do webhook
tail -f /home/deploy/my-orders/log/production.log | grep webhook
```

**No NFE.io:**
```
1. Configurações → Webhooks
2. Adicionar URL: https://seudominio.com/webhooks/nfeio
3. Eventos: Nota Emitida, Nota Cancelada
4. Testar webhook (botão "Test")
5. Verificar logs Rails
```

### ✅ Etapa 11.4: Testar Cancelamento

```
1. Abrir nota emitida
2. Clicar "Cancelar NFS-e"
3. Confirmar
4. Aguardar (~5 segundos)
5. Status deve mudar para "Cancelada"
6. Verificar no dashboard NFE.io
```

**✅ Todos os testes passaram!**

---

## 12. MANUTENÇÃO E MONITORAMENTO

### 🔄 Script de Deploy

```bash
nano ~/deploy.sh
chmod +x ~/deploy.sh
```

**Cole:**
```bash
#!/bin/bash
echo "🚀 Iniciando deploy..."

cd /home/deploy/my-orders

echo "📥 Atualizando código..."
git pull origin main

echo "📦 Instalando dependências..."
bundle install --deployment --without development test

echo "🗄️ Migrando banco..."
export $(cat .env.production | xargs)
bundle exec rails db:migrate RAILS_ENV=production

echo "🎨 Compilando assets..."
bundle exec rails assets:precompile RAILS_ENV=production

echo "🔄 Reiniciando servidor..."
sudo systemctl restart puma-service-orders
sudo systemctl restart nginx

echo "✅ Deploy concluído!"
echo "🌐 Acesse: https://seudominio.com"
```

**Usar:**
```bash
~/deploy.sh
```

### 📊 Monitoramento

**Ver logs em tempo real:**
```bash
# Rails
tail -f /home/deploy/my-orders/log/production.log

# Puma
tail -f /home/deploy/my-orders/log/puma.stdout.log

# Nginx
sudo tail -f /var/log/nginx/service_orders_access.log
sudo tail -f /var/log/nginx/service_orders_error.log

# Systemd
sudo journalctl -u puma-service-orders -f
```

**Verificar recursos:**
```bash
# CPU e Memória
htop

# Espaço em disco
df -h

# Memória detalhada
free -h

# Processos Rails
ps aux | grep puma
```

### 💾 Backup

**Script de backup:**
```bash
nano ~/backup.sh
chmod +x ~/backup.sh
```

**Cole:**
```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/home/deploy/backups"

mkdir -p $BACKUP_DIR

# Backup banco de dados
pg_dump -U deploy service_orders_production > $BACKUP_DIR/db_$DATE.sql

# Backup uploads (se houver)
tar -czf $BACKUP_DIR/uploads_$DATE.tar.gz /home/deploy/my-orders/public/uploads 2>/dev/null

# Manter últimos 7 backups
ls -t $BACKUP_DIR/db_*.sql | tail -n +8 | xargs rm -f
ls -t $BACKUP_DIR/uploads_*.tar.gz | tail -n +8 | xargs rm -f

echo "✅ Backup concluído: $DATE"
```

**Agendar backup diário (cron):**
```bash
crontab -e

# Adicionar linha:
0 2 * * * /home/deploy/backup.sh >> /home/deploy/backup.log 2>&1
```

---

## 13. TROUBLESHOOTING

### ❌ Erro: Puma não inicia

**Sintomas:**
- `systemctl status puma-service-orders` mostra failed
- Site retorna 502 Bad Gateway

**Soluções:**
```bash
# Ver logs detalhados
sudo journalctl -u puma-service-orders -n 100 --no-pager

# Verificar permissões
ls -la /home/deploy/my-orders/shared/sockets/

# Testar manualmente
cd /home/deploy/my-orders
export $(cat .env.production | xargs)
bundle exec puma -C config/puma.rb
# Ctrl+C para parar

# Se funcionar manualmente, recriar serviço
sudo systemctl daemon-reload
sudo systemctl restart puma-service-orders
```

### ❌ Erro: 502 Bad Gateway

**Causas:**
- Puma não está rodando
- Socket não existe
- Nginx não consegue acessar socket

**Soluções:**
```bash
# Verificar Puma
sudo systemctl status puma-service-orders

# Verificar socket
ls -la /home/deploy/my-orders/shared/sockets/puma.sock

# Verificar logs Nginx
sudo tail -50 /var/log/nginx/service_orders_error.log

# Recriar socket
sudo systemctl restart puma-service-orders
sudo systemctl restart nginx
```

### ❌ Erro: Assets não carregam (CSS/JS)

**Sintomas:**
- Página HTML carrega mas sem estilos
- Console do navegador mostra 404 em assets

**Soluções:**
```bash
cd /home/deploy/my-orders
export $(cat .env.production | xargs)

# Limpar assets antigos
bundle exec rails assets:clobber RAILS_ENV=production

# Recompilar
bundle exec rails assets:precompile RAILS_ENV=production

# Verificar
ls -la public/assets/
# Deve mostrar vários arquivos com hash

# Reiniciar
sudo systemctl restart puma-service-orders
```

### ❌ Erro: Database connection failed

**Sintomas:**
- Erro ao acessar site
- Logs mostram: "could not connect to server"

**Soluções:**
```bash
# Verificar PostgreSQL
sudo systemctl status postgresql

# Testar conexão
psql -U deploy -d service_orders_production -h localhost -W

# Verificar DATABASE_URL
cat /home/deploy/my-orders/.env.production | grep DATABASE_URL

# Recriar banco (CUIDADO: apaga dados!)
cd /home/deploy/my-orders
export $(cat .env.production | xargs)
bundle exec rails db:drop db:create db:migrate RAILS_ENV=production
```

### ❌ Erro: NFE.io authentication failed

**Sintomas:**
- Erro ao emitir nota: "API Key inválida"
- Status 401 nos logs

**Soluções:**
```bash
# Verificar variáveis
cat /home/deploy/my-orders/.env.production | grep NFEIO

# Testar no console
cd /home/deploy/my-orders
export $(cat .env.production | xargs)
bundle exec rails console production

# No console:
NFEIO_CONFIG
# Verificar api_key e company_id

service = NfeioService.new
# Não deve dar erro

# Se der erro, atualizar .env.production
# Copiar novas credenciais do https://app.nfe.io
```

### ❌ Erro: Certificado SSL expirado

```bash
# Renovar manualmente
sudo certbot renew

# Verificar renovação automática
sudo systemctl status certbot.timer

# Forçar renovação
sudo certbot renew --force-renewal
```

---

## 14. CHECKLIST FINAL

### ✅ Servidor

- [ ] Ubuntu 24.04 instalado
- [ ] Sistema atualizado (`apt update && apt upgrade`)
- [ ] Firewall configurado (UFW - portas 22, 80, 443)
- [ ] Usuário deploy criado
- [ ] SSH funcionando

### ✅ Dependências

- [ ] Ruby 3.2.0 (via rbenv)
- [ ] Bundler instalado
- [ ] Rails 7.1 instalado
- [ ] Node.js 18 instalado
- [ ] Yarn instalado
- [ ] PostgreSQL instalado e rodando

### ✅ Banco de Dados

- [ ] PostgreSQL criado (service_orders_production)
- [ ] Usuário deploy criado com senha
- [ ] Conexão testada
- [ ] Migrations executadas
- [ ] Seeds carregados
- [ ] Usuário admin criado

### ✅ Aplicação Rails

- [ ] Código clonado do GitHub
- [ ] .env.production configurado
- [ ] SECRET_KEY_BASE gerado
- [ ] RAILS_MASTER_KEY configurado
- [ ] Gems instaladas
- [ ] Assets compilados
- [ ] Logs criados

### ✅ NFE.io

- [ ] Conta criada no NFE.io
- [ ] Empresa configurada
- [ ] Certificado Digital e-CNPJ enviado
- [ ] API Key e Company ID copiados
- [ ] Variáveis NFEIO_* configuradas
- [ ] Migration de invoices executada
- [ ] Models, controllers e views criados
- [ ] Webhook configurado
- [ ] Nota de teste emitida com sucesso

### ✅ Nginx

- [ ] Nginx instalado
- [ ] Site configurado
- [ ] Link simbólico criado
- [ ] Configuração testada (`nginx -t`)
- [ ] Nginx reiniciado

### ✅ SSL (se usar domínio)

- [ ] Certbot instalado
- [ ] Certificado SSL obtido
- [ ] HTTPS funcionando
- [ ] Renovação automática testada

### ✅ Systemd

- [ ] Puma configurado
- [ ] Diretórios criados (sockets, logs, pids)
- [ ] Serviço puma-service-orders criado
- [ ] Serviço habilitado
- [ ] Serviço iniciado
- [ ] Status: active (running)

### ✅ Testes

- [ ] Site acessível via navegador
- [ ] Login funciona
- [ ] Dashboard carrega
- [ ] Criar ordem de serviço
- [ ] Criar cliente/técnico/peça
- [ ] Completar ordem de serviço
- [ ] Emitir nota fiscal (NFE.io)
- [ ] PDF oficial baixado
- [ ] Cancelar nota fiscal
- [ ] Webhook funcionando

### ✅ Manutenção

- [ ] Script de deploy criado
- [ ] Script de backup criado
- [ ] Cron de backup configurado
- [ ] Logs acessíveis

---

## 🎉 PARABÉNS! SISTEMA EM PRODUÇÃO!

### 📊 Resumo do Sistema

**URL de acesso:**
```
https://seudominio.com (ou http://SEU_IP)
```

**Credenciais admin:**
```
Email: admin@seudominio.com
Senha: Admin@123!Segura

⚠️ MUDE A SENHA APÓS PRIMEIRO LOGIN!
```

**Dashboards:**
```
Rails App: https://seudominio.com
NFE.io: https://app.nfe.io
Vultr: https://my.vultr.com
```

### 📚 Próximos Passos

1. **Segurança**
   - [ ] Alterar senha do admin
   - [ ] Configurar 2FA no Vultr
   - [ ] Configurar backups offsite

2. **Usuários**
   - [ ] Criar usuários normais
   - [ ] Definir permissões
   - [ ] Treinar equipe

3. **Produção**
   - [ ] Emitir primeiras notas reais
   - [ ] Monitorar erros
   - [ ] Ajustar configurações fiscais

4. **Otimização**
   - [ ] Configurar Redis (cache)
   - [ ] Configurar Sidekiq (jobs)
   - [ ] Monitoramento (New Relic, Sentry)

### 📞 Suporte

**Documentação:**
- Rails: https://guides.rubyonrails.org
- PostgreSQL: https://www.postgresql.org/docs
- Nginx: https://nginx.org/en/docs
- NFE.io: https://docs.nfe.io

**Ajuda:**
- GitHub Issues: https://github.com/cmscheffer/my-orders/issues
- NFE.io Support: suporte@nfe.io

---

## 💰 CUSTOS FINAIS

| Item | Mensal | Anual |
|------|--------|-------|
| VPS Vultr (2GB) | R$ 60 | R$ 720 |
| NFE.io Starter | R$ 20 | R$ 240 |
| Certificado Digital | R$ 20 | R$ 250 |
| Backups Vultr | R$ 6 | R$ 72 |
| **TOTAL** | **R$ 106** | **~R$ 1.280** |

---

**🚀 SISTEMA PRONTO PARA USO! 🚀**

---

*Última atualização: 2024-02-26*
*Versão: 1.0*
*Autor: Claude Code Assistant*
