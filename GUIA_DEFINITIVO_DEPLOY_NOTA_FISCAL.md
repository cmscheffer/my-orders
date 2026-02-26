# 🚀 GUIA DEFINITIVO - Deploy Ubuntu 24.04 + Nota Fiscal
## Do Zero à Produção com Estratégia Inteligente

---

## 📋 ÍNDICE

### FASE 1 - DEPLOY BÁSICO (4-5 horas)
1. [Visão Geral](#1-visão-geral)
2. [Preparação](#2-preparação)
3. [Servidor Ubuntu 24.04](#3-servidor-ubuntu-2404)
4. [Dependências](#4-dependências)
5. [PostgreSQL](#5-postgresql)
6. [Deploy Rails](#6-deploy-rails)
7. [Nota Fiscal PDF Básica](#7-nota-fiscal-pdf-básica-30-min)
8. [Nginx + SSL + Systemd](#8-nginx--ssl--systemd)
9. [Testes e Validação](#9-testes-e-validação)

### FASE 2 - MIGRAÇÃO PARA API DIRETA (1-2 semanas, opcional)
10. [Quando Migrar](#10-quando-migrar-para-api-direta)
11. [Preparação API Direta](#11-preparação-api-direta)
12. [Implementação API Direta](#12-implementação-api-direta)
13. [Migração de Dados](#13-migração-de-dados)
14. [Testes API Oficial](#14-testes-api-oficial)

### APÊNDICES
15. [Troubleshooting](#15-troubleshooting)
16. [Manutenção](#16-manutenção)
17. [Custos Detalhados](#17-custos-detalhados)

---

## 1. VISÃO GERAL

### 🎯 Estratégia Inteligente

Este guia implementa uma estratégia em 2 fases:

**FASE 1: Deploy com PDF Básico** (começar hoje)
- Sistema completo em produção
- Nota fiscal PDF (controle interno)
- Custo: R$ 66/mês
- Tempo: 4-5 horas
- ✅ Validar sistema com usuários reais
- ✅ Gerar receita imediatamente

**FASE 2: Migração para API Direta** (depois de validar)
- Emissão de NFS-e oficial
- Validade fiscal completa
- Custo adicional: +R$ 20/mês (certificado)
- Tempo: 1-2 semanas
- ✅ Apenas quando realmente precisar
- ✅ Economia de R$ 1.719/ano vs NFE.io

### 💰 Economia Total

**Começando com PDF e migrando depois:**
- 3 primeiros meses (validação): R$ 66/mês = R$ 198
- Depois com API Direta: R$ 86/mês
- **Total primeiro ano: R$ 970**

**vs Começar direto com NFE.io:**
- NFE.io desde o início: R$ 229/mês × 12 = R$ 2.748
- **Economia: R$ 1.778 no primeiro ano!**

### ⏱️ Tempo Total

| Fase | Tempo | Quando |
|------|-------|--------|
| **Fase 1: Deploy + PDF** | 4-5h | Hoje |
| **Usar e Validar** | 1-3 meses | Operação normal |
| **Fase 2: API Direta** | 1-2 semanas | Quando precisar NFS-e |

---

## 2. PREPARAÇÃO

### 📋 Checklist Pré-Requisitos

#### Para Fase 1 (hoje)
- [ ] Conta em provedor cloud (Vultr, AWS, DigitalOcean, etc)
- [ ] Cartão de crédito para VPS (~R$ 60/mês)
- [ ] Conta GitHub (código do projeto)
- [ ] Cliente SSH instalado
- [ ] Domínio próprio (opcional mas recomendado)

#### Para Fase 2 (depois)
- [ ] CNPJ da empresa
- [ ] Inscrição Municipal
- [ ] Certificado Digital e-CNPJ A1 (~R$ 250/ano)
- [ ] Código de serviço (CNAE)
- [ ] Acesso ao portal da prefeitura

### 💰 Investimento Necessário

#### Fase 1 - Começar Hoje
```
VPS 2GB RAM:        R$ 60/mês
Backups:            R$  6/mês
────────────────────────────
TOTAL FASE 1:       R$ 66/mês
INVESTIMENTO:       R$ 198 (3 meses)
```

#### Fase 2 - Quando Migrar
```
Certificado Digital: R$ 250/ano (R$ 20/mês)
────────────────────────────
ADICIONAL:          R$ 20/mês
TOTAL FASE 2:       R$ 86/mês
```

### 🎓 Conhecimentos Necessários

**Fase 1 (Básico):**
- ✅ Linha de comando Linux básica
- ✅ SSH básico
- ✅ Copiar/colar comandos

**Fase 2 (Avançado):**
- ✅ Ruby on Rails intermediário
- ✅ APIs REST
- ✅ XML/SOAP (básico)
- ✅ Certificados digitais
- ✅ Debugging

---

## 3. SERVIDOR UBUNTU 24.04

### 🖥️ Criar Servidor

**Exemplo: Vultr (recomendado)**

1. Acesse: https://my.vultr.com
2. Deploy New Server
3. Configurações:
   ```
   Type:     Cloud Compute - Shared CPU
   Location: São Paulo, Brasil
   Image:    Ubuntu 24.04 LTS x64
   Plan:     $12/mo (2GB RAM, 55GB SSD)
   Features: ✅ IPv6, ✅ Auto Backups
   Hostname: my-orders-prod
   ```
4. Deploy Now
5. Copie: IP do servidor (ex: 123.45.67.89)

### 🔐 Configuração Inicial

```bash
# Conectar como root
ssh root@SEU_IP_AQUI

# Atualizar sistema
apt update && apt upgrade -y

# Criar usuário deploy
adduser deploy
# Digite senha forte: Ex: Deploy@2024!Prod
usermod -aG sudo deploy

# Configurar firewall
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable

# Trocar para usuário deploy
su - deploy
```

---

## 4. DEPENDÊNCIAS

### 💎 Instalar Ruby

```bash
# Como usuário deploy
cd ~

# Dependências
sudo apt install -y git curl build-essential libssl-dev \
  libreadline-dev zlib1g-dev libpq-dev libyaml-dev \
  libncurses5-dev libffi-dev libgdbm-dev

# rbenv
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-installer | bash

# PATH
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

# Instalar Ruby 3.2.0
rbenv install 3.2.0
rbenv global 3.2.0

# Verificar
ruby -v  # Deve mostrar: ruby 3.2.0

# Bundler e Rails
gem install bundler rails -v 7.1.6
```

### 📦 Instalar Node.js e Yarn

```bash
# Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install -y yarn

# Verificar
node -v   # v18.x.x
yarn -v   # 1.x.x
```

---

## 5. POSTGRESQL

```bash
# Instalar
sudo apt install -y postgresql postgresql-contrib libpq-dev

# Criar banco e usuário
sudo -u postgres psql << 'EOF'
CREATE USER deploy WITH PASSWORD 'SuaSenhaSegura@2024!';
CREATE DATABASE service_orders_production OWNER deploy;
GRANT ALL PRIVILEGES ON DATABASE service_orders_production TO deploy;
\q
EOF

# Testar
psql -U deploy -d service_orders_production -h localhost -W
# Digite a senha, depois \q para sair
```

---

## 6. DEPLOY RAILS

### 📂 Clonar Projeto

```bash
cd /home/deploy
git clone https://github.com/cmscheffer/my-orders.git
cd my-orders
```

### ⚙️ Configurar Ambiente

```bash
# Criar .env.production
cat > .env.production << 'EOF'
RAILS_ENV=production
DATABASE_URL=postgresql://deploy:SuaSenhaSegura@2024!@localhost/service_orders_production
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
DEVISE_MAILER_HOST=seudominio.com
EOF

# Gerar secrets
bundle install
SECRET_KEY=$(bundle exec rails secret)
echo "SECRET_KEY_BASE=$SECRET_KEY" >> .env.production

# Se não tiver master.key
if [ ! -f config/master.key ]; then
  EDITOR="nano" bundle exec rails credentials:edit
  # Cole o SECRET_KEY_BASE gerado acima
  # Salve: Ctrl+O, Enter, Ctrl+X
  echo "RAILS_MASTER_KEY=$(cat config/master.key)" >> .env.production
fi

# Proteger arquivo
chmod 600 .env.production
```

### 📦 Instalar e Preparar

```bash
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

# Criar admin
bundle exec rails runner "
  User.create!(
    name: 'Administrador',
    email: 'admin@admin.com',
    password: 'Admin@2024!Prod',
    password_confirmation: 'Admin@2024!Prod',
    role: 'admin'
  )
" RAILS_ENV=production
```

---

## 7. NOTA FISCAL PDF BÁSICA (30 min)

### 🎯 O Que Será Implementado

- ✅ Geração de PDF profissional
- ✅ Cálculo automático de impostos (ISS, PIS, COFINS)
- ✅ Numeração sequencial
- ✅ Logo da empresa
- ✅ Dados do cliente
- ✅ Listagem de serviços
- ❌ SEM validade fiscal (controle interno apenas)

### 📦 Adicionar Gem Prawn

```bash
cd /home/deploy/my-orders

# Verificar se já tem prawn no Gemfile
grep -q "gem 'prawn'" Gemfile || echo "gem 'prawn', '~> 2.4'" >> Gemfile
grep -q "gem 'prawn-table'" Gemfile || echo "gem 'prawn-table', '~> 0.2'" >> Gemfile

bundle install
```

### 🗄️ Criar Migration de Invoices

```bash
bundle exec rails generate migration CreateInvoices
```

Editar a migration gerada:

```bash
nano db/migrate/$(ls -t db/migrate/ | head -1)
```

Cole:

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
      t.integer :status, default: 0  # 0=draft, 1=issued, 2=cancelled
      
      # Valores
      t.decimal :service_value, precision: 10, scale: 2
      t.decimal :total_value, precision: 10, scale: 2
      
      # Impostos calculados
      t.decimal :iss_rate, precision: 5, scale: 2, default: 5.00
      t.decimal :iss_value, precision: 10, scale: 2
      t.decimal :pis_value, precision: 10, scale: 2
      t.decimal :cofins_value, precision: 10, scale: 2
      t.decimal :net_value, precision: 10, scale: 2
      
      # Dados do cliente (snapshot)
      t.string :customer_name
      t.string :customer_cpf_cnpj
      t.string :customer_email
      t.string :customer_address
      t.string :customer_city
      t.string :customer_state
      t.string :customer_zip_code
      
      # Observações
      t.text :notes
      
      t.timestamps
    end
    
    add_index :invoices, :invoice_number, unique: true
    add_index :invoices, :status
  end
end
```

Executar migration:

```bash
export $(cat .env.production | xargs)
bundle exec rails db:migrate RAILS_ENV=production
```

### 📝 Criar Model Invoice

```bash
nano app/models/invoice.rb
```

Cole:

```ruby
class Invoice < ApplicationRecord
  belongs_to :service_order
  
  # Enums
  enum status: {
    draft: 0,
    issued: 1,
    cancelled: 2
  }
  
  # Validações
  validates :invoice_number, presence: true, uniqueness: true
  validates :serie, presence: true
  validates :total_value, numericality: { greater_than: 0 }
  validates :customer_name, presence: true
  
  # Callbacks
  before_validation :generate_invoice_number, on: :create
  before_validation :copy_service_order_data, on: :create
  before_save :calculate_taxes
  before_create :set_issued_at
  
  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :current_year, -> { where("EXTRACT(YEAR FROM created_at) = ?", Date.current.year) }
  
  # Métodos
  def can_be_cancelled?
    issued? && cancelled_at.nil?
  end
  
  def formatted_invoice_number
    "#{serie}-#{invoice_number}"
  end
  
  def formatted_value(value)
    "R$ #{format('%.2f', value || 0)}".gsub('.', ',')
  end
  
  def formatted_cpf_cnpj
    return '' unless customer_cpf_cnpj.present?
    numbers = customer_cpf_cnpj.gsub(/\D/, '')
    
    if numbers.length == 11
      "#{numbers[0..2]}.#{numbers[3..5]}.#{numbers[6..8]}-#{numbers[9..10]}"
    elsif numbers.length == 14
      "#{numbers[0..1]}.#{numbers[2..4]}.#{numbers[5..7]}/#{numbers[8..11]}-#{numbers[12..13]}"
    else
      customer_cpf_cnpj
    end
  end
  
  private
  
  def generate_invoice_number
    return if invoice_number.present?
    
    last_invoice = Invoice.current_year
                          .where(serie: serie || "001")
                          .order(invoice_number: :desc)
                          .first
    
    if last_invoice
      last_number = last_invoice.invoice_number.to_i
      self.invoice_number = (last_number + 1).to_s.rjust(6, "0")
    else
      self.invoice_number = "000001"
    end
  end
  
  def copy_service_order_data
    return unless service_order
    
    self.service_value = service_order.service_value || service_order.total_value
    self.total_value = service_order.total_value
    self.customer_name = service_order.customer_name
    self.customer_email = service_order.customer_email
    # Adicionar mais campos conforme disponível no ServiceOrder
  end
  
  def calculate_taxes
    return unless total_value
    
    self.iss_rate ||= 5.00
    self.iss_value = (total_value * (iss_rate / 100.0)).round(2)
    self.pis_value = (total_value * 0.0065).round(2)
    self.cofins_value = (total_value * 0.03).round(2)
    self.net_value = (total_value - iss_value - pis_value - cofins_value).round(2)
  end
  
  def set_issued_at
    self.issued_at = Time.current if self.issued_at.nil?
  end
end
```

### 🎨 Criar Service de PDF

```bash
mkdir -p app/services
nano app/services/invoice_pdf_generator.rb
```

Cole:

```ruby
require 'prawn'
require 'prawn/table'

class InvoicePdfGenerator
  def initialize(invoice)
    @invoice = invoice
    @company = CompanySetting.instance
  end
  
  def generate
    pdf = Prawn::Document.new(page_size: 'A4', margin: 40)
    
    # Header com logo
    add_header(pdf)
    
    # Dados da nota
    add_invoice_info(pdf)
    
    # Dados do prestador
    add_company_info(pdf)
    
    # Dados do tomador
    add_customer_info(pdf)
    
    # Serviços
    add_services(pdf)
    
    # Impostos
    add_taxes(pdf)
    
    # Valores
    add_totals(pdf)
    
    # Observações
    add_notes(pdf) if @invoice.notes.present?
    
    # Footer
    add_footer(pdf)
    
    pdf.render
  end
  
  private
  
  def add_header(pdf)
    # Logo (se existir)
    if @company && @company.logo?
      begin
        logo_path = Rails.root.join('public', @company.logo_path)
        pdf.image logo_path, width: 100, height: 50 if File.exist?(logo_path)
      rescue => e
        Rails.logger.error "Erro ao carregar logo: #{e.message}"
      end
    end
    
    pdf.move_down 20
    
    # Título
    pdf.font_size 20
    pdf.text "NOTA FISCAL DE SERVIÇO", align: :center, style: :bold
    pdf.text "(Controle Interno)", align: :center, size: 10
    
    pdf.move_down 20
    pdf.stroke_horizontal_rule
    pdf.move_down 10
  end
  
  def add_invoice_info(pdf)
    pdf.font_size 10
    
    data = [
      ["Número", @invoice.formatted_invoice_number],
      ["Data de Emissão", I18n.l(@invoice.issued_at, format: :long)],
      ["Status", @invoice.status.humanize]
    ]
    
    pdf.table(data, width: pdf.bounds.width, cell_style: { borders: [:bottom], padding: 5 }) do
      column(0).font_style = :bold
      column(0).width = 150
    end
    
    pdf.move_down 15
  end
  
  def add_company_info(pdf)
    pdf.font_size 12
    pdf.text "DADOS DO PRESTADOR", style: :bold
    pdf.move_down 5
    
    pdf.font_size 10
    
    if @company
      pdf.text @company.company_name || "Empresa"
      pdf.text "CNPJ: #{@company.formatted_cnpj}" if @company.cnpj.present?
      pdf.text "#{@company.address}, #{@company.city} - #{@company.state}" if @company.address.present?
      pdf.text "CEP: #{@company.zip_code}" if @company.zip_code.present?
      pdf.text "Telefone: #{@company.phone}" if @company.phone.present?
      pdf.text "Email: #{@company.email}" if @company.email.present?
    else
      pdf.text "Configurar dados da empresa em: Configurações > Empresa"
    end
    
    pdf.move_down 15
  end
  
  def add_customer_info(pdf)
    pdf.font_size 12
    pdf.text "DADOS DO TOMADOR", style: :bold
    pdf.move_down 5
    
    pdf.font_size 10
    pdf.text @invoice.customer_name
    pdf.text "CPF/CNPJ: #{@invoice.formatted_cpf_cnpj}" if @invoice.customer_cpf_cnpj.present?
    pdf.text "Email: #{@invoice.customer_email}" if @invoice.customer_email.present?
    
    if @invoice.customer_address.present?
      address_parts = []
      address_parts << @invoice.customer_address if @invoice.customer_address.present?
      address_parts << @invoice.customer_city if @invoice.customer_city.present?
      address_parts << @invoice.customer_state if @invoice.customer_state.present?
      pdf.text address_parts.join(", ")
    end
    
    pdf.text "CEP: #{@invoice.customer_zip_code}" if @invoice.customer_zip_code.present?
    
    pdf.move_down 15
  end
  
  def add_services(pdf)
    pdf.font_size 12
    pdf.text "DISCRIMINAÇÃO DOS SERVIÇOS", style: :bold
    pdf.move_down 5
    
    pdf.font_size 10
    
    # Descrição do serviço (da ordem de serviço)
    if @invoice.service_order
      pdf.text @invoice.service_order.description || "Serviços prestados"
    else
      pdf.text "Serviços prestados conforme ordem de serviço"
    end
    
    pdf.move_down 15
  end
  
  def add_taxes(pdf)
    pdf.font_size 12
    pdf.text "IMPOSTOS E RETENÇÕES", style: :bold
    pdf.move_down 5
    
    pdf.font_size 10
    
    data = [
      ["Imposto", "Alíquota", "Valor"],
      ["ISS", "#{@invoice.iss_rate}%", @invoice.formatted_value(@invoice.iss_value)],
      ["PIS", "0,65%", @invoice.formatted_value(@invoice.pis_value)],
      ["COFINS", "3,00%", @invoice.formatted_value(@invoice.cofins_value)]
    ]
    
    pdf.table(data, width: pdf.bounds.width, header: true) do
      row(0).font_style = :bold
      row(0).background_color = 'EEEEEE'
      columns(2).align = :right
    end
    
    pdf.move_down 15
  end
  
  def add_totals(pdf)
    pdf.font_size 12
    pdf.text "VALORES", style: :bold
    pdf.move_down 5
    
    pdf.font_size 10
    
    data = [
      ["Valor Bruto dos Serviços", @invoice.formatted_value(@invoice.total_value)],
      ["(-) Impostos", @invoice.formatted_value(@invoice.iss_value + @invoice.pis_value + @invoice.cofins_value)],
      ["Valor Líquido", @invoice.formatted_value(@invoice.net_value)]
    ]
    
    pdf.table(data, width: pdf.bounds.width, cell_style: { borders: [:bottom], padding: 5 }) do
      column(0).font_style = :bold
      column(1).align = :right
      row(-1).font_style = :bold
      row(-1).background_color = 'EEEEEE'
    end
    
    pdf.move_down 15
  end
  
  def add_notes(pdf)
    pdf.font_size 12
    pdf.text "OBSERVAÇÕES", style: :bold
    pdf.move_down 5
    
    pdf.font_size 10
    pdf.text @invoice.notes
    
    pdf.move_down 15
  end
  
  def add_footer(pdf)
    pdf.move_down 30
    
    pdf.stroke_horizontal_rule
    pdf.move_down 10
    
    pdf.font_size 8
    pdf.text "Este documento não possui validade fiscal. Destina-se apenas ao controle interno.", 
             align: :center, style: :italic
    pdf.text "Para nota fiscal oficial, aguarde a implementação da integração com a prefeitura.", 
             align: :center, style: :italic
    
    pdf.move_down 10
    pdf.text "Gerado em #{I18n.l(Time.current, format: :long)}", align: :center, size: 7
  end
end
```

### 🎮 Criar Controller

```bash
nano app/controllers/invoices_controller.rb
```

Cole:

```ruby
class InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_service_order, only: [:new, :create]
  before_action :set_invoice, only: [:show, :edit, :update, :cancel, :download_pdf]
  
  def index
    @invoices = Invoice.includes(:service_order).recent.page(params[:page]).per(15)
    @invoices = @invoices.by_status(params[:status]) if params[:status].present?
  end
  
  def show
  end
  
  def new
    unless @service_order.completed?
      redirect_to @service_order, alert: "Ordem de serviço deve estar completa para gerar nota fiscal"
      return
    end
    
    @invoice = @service_order.build_invoice(
      serie: "001",
      iss_rate: 5.00
    )
  end
  
  def create
    @invoice = @service_order.build_invoice(invoice_params)
    @invoice.status = :issued
    
    if @invoice.save
      redirect_to @invoice, notice: "✅ Nota fiscal gerada com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    unless @invoice.draft?
      redirect_to @invoice, alert: "Nota fiscal não pode ser editada após emissão"
    end
  end
  
  def update
    if @invoice.draft? && @invoice.update(invoice_params)
      redirect_to @invoice, notice: "Nota fiscal atualizada!"
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def cancel
    unless @invoice.can_be_cancelled?
      redirect_to @invoice, alert: "Nota fiscal não pode ser cancelada"
      return
    end
    
    @invoice.update(status: :cancelled, cancelled_at: Time.current)
    redirect_to @invoice, notice: "✅ Nota fiscal cancelada com sucesso!"
  end
  
  def download_pdf
    pdf = InvoicePdfGenerator.new(@invoice).generate
    
    send_data pdf,
              filename: "nota_fiscal_#{@invoice.formatted_invoice_number}.pdf",
              type: 'application/pdf',
              disposition: 'attachment'
  end
  
  private
  
  def set_service_order
    @service_order = ServiceOrder.find(params[:service_order_id])
  end
  
  def set_invoice
    @invoice = Invoice.find(params[:id])
  end
  
  def invoice_params
    params.require(:invoice).permit(
      :serie,
      :iss_rate,
      :customer_name,
      :customer_cpf_cnpj,
      :customer_email,
      :customer_address,
      :customer_city,
      :customer_state,
      :customer_zip_code,
      :notes
    )
  end
end
```

### 🛣️ Adicionar Rotas

```bash
nano config/routes.rb
```

Adicionar antes do `end` final:

```ruby
  # Invoices (Notas Fiscais PDF)
  resources :invoices, only: [:index, :show, :edit, :update] do
    member do
      delete :cancel
      get :download_pdf
    end
  end
  
  resources :service_orders do
    resources :invoices, only: [:new, :create]
  end
```

### 🔗 Atualizar ServiceOrder Model

```bash
nano app/models/service_order.rb
```

Adicionar após `belongs_to :user`:

```ruby
  has_one :invoice, dependent: :destroy
  
  def can_generate_invoice?
    completed? && total_value.present? && total_value > 0 && invoice.nil?
  end
```

### 🎨 Criar Views

```bash
mkdir -p app/views/invoices
```

**Index:**
```bash
nano app/views/invoices/index.html.erb
```

Cole:

```erb
<div class="container mt-4">
  <div class="d-flex justify-content-between align-items-center mb-4">
    <h1><i class="bi bi-receipt"></i> Notas Fiscais PDF</h1>
  </div>
  
  <!-- Filtros -->
  <div class="card mb-4">
    <div class="card-body">
      <%= form_with url: invoices_path, method: :get, local: true, class: "row g-3" do %>
        <div class="col-md-4">
          <%= select_tag :status, 
              options_for_select([
                ["Todos os Status", ""],
                ["Emitida", "issued"],
                ["Cancelada", "cancelled"]
              ], params[:status]),
              class: "form-select" %>
        </div>
        
        <div class="col-md-2">
          <%= submit_tag "Filtrar", class: "btn btn-primary w-100" %>
        </div>
      <% end %>
    </div>
  </div>
  
  <!-- Tabela -->
  <div class="card">
    <div class="card-body">
      <% if @invoices.any? %>
        <div class="table-responsive">
          <table class="table table-hover">
            <thead>
              <tr>
                <th>Número</th>
                <th>OS</th>
                <th>Cliente</th>
                <th>Emissão</th>
                <th>Valor</th>
                <th>Status</th>
                <th>Ações</th>
              </tr>
            </thead>
            <tbody>
              <% @invoices.each do |invoice| %>
                <tr>
                  <td><%= invoice.formatted_invoice_number %></td>
                  <td>
                    <%= link_to "##{invoice.service_order.id}", invoice.service_order %>
                  </td>
                  <td><%= invoice.customer_name %></td>
                  <td><%= l(invoice.issued_at, format: :short) if invoice.issued_at %></td>
                  <td><strong><%= invoice.formatted_value(invoice.total_value) %></strong></td>
                  <td>
                    <% if invoice.issued? %>
                      <span class="badge bg-success">Emitida</span>
                    <% elsif invoice.cancelled? %>
                      <span class="badge bg-danger">Cancelada</span>
                    <% end %>
                  </td>
                  <td>
                    <%= link_to "Ver", invoice, class: "btn btn-sm btn-info" %>
                    <%= link_to "PDF", download_pdf_invoice_path(invoice), 
                        class: "btn btn-sm btn-danger", target: "_blank" %>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
        
        <div class="mt-3">
          <%= paginate @invoices %>
        </div>
      <% else %>
        <p class="text-center text-muted">Nenhuma nota fiscal encontrada.</p>
      <% end %>
    </div>
  </div>
</div>
```

**Show:**
```bash
nano app/views/invoices/show.html.erb
```

Cole:

```erb
<div class="container mt-4">
  <div class="d-flex justify-content-between align-items-center mb-4">
    <h1>
      <i class="bi bi-receipt"></i> 
      Nota Fiscal <%= @invoice.formatted_invoice_number %>
    </h1>
    
    <div>
      <%= link_to "Voltar", invoices_path, class: "btn btn-secondary" %>
      <%= link_to "Baixar PDF", download_pdf_invoice_path(@invoice), 
          class: "btn btn-danger", target: "_blank" %>
      
      <% if @invoice.can_be_cancelled? %>
        <%= button_to "Cancelar", cancel_invoice_path(@invoice), 
            method: :delete, 
            class: "btn btn-warning",
            data: { confirm: "Tem certeza que deseja cancelar esta nota fiscal?" } %>
      <% end %>
    </div>
  </div>
  
  <!-- Status -->
  <div class="alert <%= @invoice.issued? ? 'alert-success' : 'alert-danger' %>">
    <strong>Status:</strong>
    <% if @invoice.issued? %>
      ✅ Nota fiscal emitida em <%= l(@invoice.issued_at, format: :long) %>
    <% elsif @invoice.cancelled? %>
      ❌ Nota fiscal cancelada em <%= l(@invoice.cancelled_at, format: :long) %>
    <% end %>
  </div>
  
  <!-- Informações Básicas -->
  <div class="card mb-4">
    <div class="card-header">
      <h5 class="mb-0">Informações da Nota</h5>
    </div>
    <div class="card-body">
      <div class="row">
        <div class="col-md-4">
          <strong>Número:</strong><br>
          <%= @invoice.formatted_invoice_number %>
        </div>
        <div class="col-md-4">
          <strong>Ordem de Serviço:</strong><br>
          <%= link_to "##{@invoice.service_order.id}", @invoice.service_order %>
        </div>
        <div class="col-md-4">
          <strong>Data de Emissão:</strong><br>
          <%= l(@invoice.issued_at, format: :long) if @invoice.issued_at %>
        </div>
      </div>
    </div>
  </div>
  
  <!-- Dados do Cliente -->
  <div class="card mb-4">
    <div class="card-header">
      <h5 class="mb-0">Dados do Tomador</h5>
    </div>
    <div class="card-body">
      <p><strong>Nome:</strong> <%= @invoice.customer_name %></p>
      <p><strong>CPF/CNPJ:</strong> <%= @invoice.formatted_cpf_cnpj %></p>
      <p><strong>Email:</strong> <%= @invoice.customer_email %></p>
      <% if @invoice.customer_address.present? %>
        <p>
          <strong>Endereço:</strong>
          <%= @invoice.customer_address %>,
          <%= @invoice.customer_city %> - <%= @invoice.customer_state %>
          <% if @invoice.customer_zip_code.present? %>
            <br>CEP: <%= @invoice.customer_zip_code %>
          <% end %>
        </p>
      <% end %>
    </div>
  </div>
  
  <!-- Valores e Impostos -->
  <div class="card mb-4">
    <div class="card-header">
      <h5 class="mb-0">Valores e Impostos</h5>
    </div>
    <div class="card-body">
      <table class="table">
        <tr>
          <td><strong>Valor Bruto dos Serviços:</strong></td>
          <td class="text-end"><strong><%= @invoice.formatted_value(@invoice.total_value) %></strong></td>
        </tr>
        <tr>
          <td>ISS (<%= @invoice.iss_rate %>%):</td>
          <td class="text-end text-danger">- <%= @invoice.formatted_value(@invoice.iss_value) %></td>
        </tr>
        <tr>
          <td>PIS (0,65%):</td>
          <td class="text-end text-danger">- <%= @invoice.formatted_value(@invoice.pis_value) %></td>
        </tr>
        <tr>
          <td>COFINS (3%):</td>
          <td class="text-end text-danger">- <%= @invoice.formatted_value(@invoice.cofins_value) %></td>
        </tr>
        <tr class="table-primary">
          <td><strong>Valor Líquido:</strong></td>
          <td class="text-end"><strong><%= @invoice.formatted_value(@invoice.net_value) %></strong></td>
        </tr>
      </table>
    </div>
  </div>
  
  <!-- Observações -->
  <% if @invoice.notes.present? %>
    <div class="card mb-4">
      <div class="card-header">
        <h5 class="mb-0">Observações</h5>
      </div>
      <div class="card-body">
        <%= simple_format(@invoice.notes) %>
      </div>
    </div>
  <% end %>
  
  <!-- Aviso -->
  <div class="alert alert-info">
    <i class="bi bi-info-circle"></i>
    <strong>Atenção:</strong> Esta nota fiscal PDF não possui validade fiscal oficial.
    É destinada apenas ao controle interno da empresa.
    <% if current_user.admin? %>
      <br>
      <small>
        Para emissão de NFS-e oficial, configure a integração com a API da prefeitura.
        <%= link_to "Ver guia de migração", "#fase-2", class: "alert-link" %>
      </small>
    <% end %>
  </div>
</div>
```

**New:**
```bash
nano app/views/invoices/new.html.erb
```

Cole:

```erb
<div class="container mt-4">
  <h1>Nova Nota Fiscal PDF</h1>
  <p class="text-muted">Ordem de Serviço #<%= @service_order.id %></p>
  
  <%= form_with model: [@service_order, @invoice], local: true do |f| %>
    <% if @invoice.errors.any? %>
      <div class="alert alert-danger">
        <h5><%= pluralize(@invoice.errors.count, "erro") %> encontrado:</h5>
        <ul>
          <% @invoice.errors.full_messages.each do |message| %>
            <li><%= message %></li>
          <% end %>
        </ul>
      </div>
    <% end %>
    
    <!-- Dados da Nota -->
    <div class="card mb-4">
      <div class="card-header">
        <h5>Dados da Nota</h5>
      </div>
      <div class="card-body">
        <div class="row">
          <div class="col-md-6">
            <%= f.label :serie, "Série" %>
            <%= f.text_field :serie, class: "form-control", value: "001", readonly: true %>
          </div>
          <div class="col-md-6">
            <%= f.label :iss_rate, "Alíquota ISS (%)" %>
            <%= f.number_field :iss_rate, class: "form-control", step: 0.01, min: 0, max: 100 %>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Dados do Cliente -->
    <div class="card mb-4">
      <div class="card-header">
        <h5>Dados do Tomador (Cliente)</h5>
      </div>
      <div class="card-body">
        <div class="mb-3">
          <%= f.label :customer_name, "Nome/Razão Social" %>
          <%= f.text_field :customer_name, class: "form-control", required: true %>
        </div>
        
        <div class="row">
          <div class="col-md-6 mb-3">
            <%= f.label :customer_cpf_cnpj, "CPF/CNPJ" %>
            <%= f.text_field :customer_cpf_cnpj, class: "form-control" %>
          </div>
          <div class="col-md-6 mb-3">
            <%= f.label :customer_email, "Email" %>
            <%= f.email_field :customer_email, class: "form-control" %>
          </div>
        </div>
        
        <div class="mb-3">
          <%= f.label :customer_address, "Endereço" %>
          <%= f.text_field :customer_address, class: "form-control" %>
        </div>
        
        <div class="row">
          <div class="col-md-4 mb-3">
            <%= f.label :customer_city, "Cidade" %>
            <%= f.text_field :customer_city, class: "form-control" %>
          </div>
          <div class="col-md-4 mb-3">
            <%= f.label :customer_state, "Estado" %>
            <%= f.text_field :customer_state, class: "form-control", maxlength: 2 %>
          </div>
          <div class="col-md-4 mb-3">
            <%= f.label :customer_zip_code, "CEP" %>
            <%= f.text_field :customer_zip_code, class: "form-control" %>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Observações -->
    <div class="card mb-4">
      <div class="card-header">
        <h5>Observações</h5>
      </div>
      <div class="card-body">
        <%= f.text_area :notes, class: "form-control", rows: 4, 
            placeholder: "Informações adicionais (opcional)" %>
      </div>
    </div>
    
    <!-- Resumo -->
    <div class="card mb-4">
      <div class="card-header bg-primary text-white">
        <h5 class="mb-0">Resumo de Valores</h5>
      </div>
      <div class="card-body">
        <p><strong>Valor dos Serviços:</strong> <%= number_to_currency(@service_order.total_value) %></p>
        <p class="text-muted">
          <small>Os impostos (ISS, PIS, COFINS) serão calculados automaticamente.</small>
        </p>
      </div>
    </div>
    
    <div class="d-flex justify-content-between">
      <%= link_to "Cancelar", @service_order, class: "btn btn-secondary" %>
      <%= f.submit "Gerar Nota Fiscal", class: "btn btn-primary btn-lg" %>
    </div>
  <% end %>
</div>
```

### 🔗 Adicionar Link no Service Order Show

```bash
nano app/views/service_orders/show.html.erb
```

Adicionar botão antes do botão "Editar" (procurar e adicionar):

```erb
<% if @service_order.can_generate_invoice? %>
  <%= link_to "Emitir Nota Fiscal", new_service_order_invoice_path(@service_order), 
      class: "btn btn-success" %>
<% elsif @service_order.invoice %>
  <%= link_to "Ver Nota Fiscal", @service_order.invoice, class: "btn btn-info" %>
<% end %>
```

### 🌍 Adicionar Traduções PT-BR

```bash
nano config/locales/pt-BR.yml
```

Adicionar:

```yaml
pt-BR:
  activerecord:
    models:
      invoice: "Nota Fiscal"
    attributes:
      invoice:
        invoice_number: "Número"
        serie: "Série"
        issued_at: "Emitida em"
        status: "Status"
        total_value: "Valor Total"
        customer_name: "Cliente"
        customer_cpf_cnpj: "CPF/CNPJ"
        iss_rate: "Alíquota ISS"
        notes: "Observações"
```

### ✅ Testar Implementação

```bash
# Reiniciar servidor (se rodando)
# Testar no navegador:
# 1. Completar uma ordem de serviço
# 2. Clicar "Emitir Nota Fiscal"
# 3. Preencher dados do cliente
# 4. Gerar nota
# 5. Baixar PDF
```

**🎉 FASE 1 COMPLETA! Nota Fiscal PDF Básica funcionando!**

---

## 8. NGINX + SSL + SYSTEMD

### 🌐 Instalar Nginx

```bash
sudo apt install -y nginx

# Configurar site
sudo nano /etc/nginx/sites-available/my-orders
```

Cole:

```nginx
upstream puma {
  server unix:///home/deploy/my-orders/shared/sockets/puma.sock;
}

server {
  listen 80;
  listen [::]:80;
  
  server_name seudominio.com www.seudominio.com;
  # Ou use o IP se não tiver domínio:
  # server_name 123.45.67.89;
  
  root /home/deploy/my-orders/public;
  
  access_log /var/log/nginx/my_orders_access.log;
  error_log /var/log/nginx/my_orders_error.log info;
  
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

Ativar:

```bash
sudo ln -s /etc/nginx/sites-available/my-orders /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
```

### 🔒 SSL (Let's Encrypt)

**Apenas se tiver domínio:**

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d seudominio.com -d www.seudominio.com
# Siga as instruções, escolha opção 2 (redirecionar HTTPS)
```

### 🤖 Configurar Puma

```bash
# Diretórios
mkdir -p /home/deploy/my-orders/shared/sockets
mkdir -p /home/deploy/my-orders/log
mkdir -p /home/deploy/my-orders/tmp/pids

# Editar config Puma
nano /home/deploy/my-orders/config/puma.rb
```

Ajustar para produção:

```ruby
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

preload_app!

plugin :tmp_restart

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

### 🤖 Criar Serviço Systemd

```bash
sudo nano /etc/systemd/system/my-orders.service
```

Cole:

```ini
[Unit]
Description=My Orders Rails App
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

Ativar:

```bash
sudo systemctl daemon-reload
sudo systemctl enable my-orders
sudo systemctl start my-orders
sudo systemctl status my-orders
```

---

## 9. TESTES E VALIDAÇÃO

### ✅ Checklist de Testes

```bash
# 1. Acessar site
curl http://SEU_IP

# 2. Ver logs
tail -f /home/deploy/my-orders/log/production.log
tail -f /home/deploy/my-orders/log/puma.stdout.log

# 3. Verificar serviços
sudo systemctl status my-orders
sudo systemctl status nginx
sudo systemctl status postgresql
```

### 🌐 Testes no Navegador

1. **Acesse:** http://SEU_IP ou https://seudominio.com
2. **Login:** admin@admin.com / Admin@2024!Prod
3. **Testar:**
   - [ ] Dashboard carrega
   - [ ] Criar ordem de serviço
   - [ ] Completar ordem
   - [ ] **Emitir nota fiscal PDF**
   - [ ] **Baixar PDF da nota**
   - [ ] Ver relatórios

---

## 🎉 FIM DA FASE 1!

**Parabéns! Você agora tem:**
- ✅ Sistema Rails em produção
- ✅ Nota Fiscal PDF funcionando
- ✅ Custo: R$ 66/mês
- ✅ Sistema validado e gerando receita

**Use por 1-3 meses para validar com clientes reais!**

**Quando precisar de NFS-e oficial → Continue para FASE 2**

---

# FASE 2 - MIGRAÇÃO PARA API DIRETA

## 10. QUANDO MIGRAR PARA API DIRETA

### 🎯 Sinais de que é hora de migrar

Migre para API direta quando:

1. **Clientes pedem NFS-e oficial**
   - Cliente precisa para abater impostos
   - Cliente exige nota fiscal eletrônica
   - Empresa/governo exige

2. **Volume justifica o investimento**
   - Está emitindo > 50 notas/mês
   - Economia anual compensa desenvolvimento
   - 50 notas/mês × 12 = R$ 1.719/ano economizado

3. **Tem recursos técnicos**
   - Desenvolvedor Ruby experiente disponível
   - 1-2 semanas de tempo de desenvolvimento
   - Capacidade de manutenção

4. **Opera em cidade suportada**
   - Prefeitura tem API de NFS-e
   - Documentação disponível
   - Sistema funcionando

### ❌ Quando NÃO migrar ainda

Continue com PDF básico se:

- ✅ Nenhum cliente pediu NFS-e oficial
- ✅ Volume < 50 notas/mês
- ✅ Sem desenvolvedor experiente
- ✅ Prefeitura sem API disponível

**Nestes casos, considere NFE.io** (R$ 229/mês) se realmente precisar NFS-e oficial.

---

## 11. PREPARAÇÃO API DIRETA

### 📋 Requisitos Adicionais

#### Certificado Digital e-CNPJ A1

**O que é:**
- Certificado digital para assinar documentos fiscais
- Tipo A1 (arquivo .pfx)
- Validade: 1 ano
- Custo: R$ 150-300/ano

**Onde comprar:**
- Serasa Experian: https://serasa.certificado digital.com.br
- Certisign: https://loja.certisign.com.br
- Valid: https://www.validcertificadora.com.br
- Soluti: https://www.soluti.com.br

**Processo:**
1. Escolher Autoridade Certificadora (AC)
2. Fazer videoconferência (validação)
3. Receber certificado .pfx por email
4. Guardar senha em local seguro

**Custo adicional:** +R$ 20/mês (R$ 250/ano)

#### Dados da Empresa

- [ ] Razão Social completa
- [ ] CNPJ
- [ ] Inscrição Municipal
- [ ] Endereço completo com CEP
- [ ] Telefone e email
- [ ] Código de atividade (CNAE)
- [ ] Regime tributário

#### Acesso à Prefeitura

- [ ] Portal da prefeitura
- [ ] Documentação da API
- [ ] Credenciais de homologação (teste)
- [ ] Credenciais de produção

### 📚 Gem br_nfe

Vamos usar a gem **br_nfe** que suporta várias prefeituras:

```bash
cd /home/deploy/my-orders

# Adicionar ao Gemfile
echo "gem 'br_nfe', '~> 4.0'" >> Gemfile

bundle install
```

**Cidades suportadas pela br_nfe:**
- São Paulo (SP)
- Rio de Janeiro (RJ)
- Belo Horizonte (MG)
- Curitiba (PR)
- Porto Alegre (RS)
- Brasília (DF)
- Salvador (BA)
- Fortaleza (CE)
- E muitas outras...

**Ver lista completa:**
https://github.com/asseinfo/br_nfe

---

## 12. IMPLEMENTAÇÃO API DIRETA

### 🗄️ Adicionar Campos à Invoice

```bash
bundle exec rails generate migration AddApiFieldsToInvoices
```

Editar migration:

```bash
nano db/migrate/$(ls -t db/migrate/ | head -1)
```

Cole:

```ruby
class AddApiFieldsToInvoices < ActiveRecord::Migration[7.1]
  def change
    add_column :invoices, :nfse_number, :string
    add_column :invoices, :verification_code, :string
    add_column :invoices, :xml_file, :text
    add_column :invoices, :xml_response, :text
    add_column :invoices, :rps_number, :string
    add_column :invoices, :rps_serie, :string
    add_column :invoices, :api_status, :string
    add_column :invoices, :api_error, :text
    
    add_index :invoices, :nfse_number
    add_index :invoices, :rps_number
  end
end
```

Executar:

```bash
export $(cat .env.production | xargs)
bundle exec rails db:migrate RAILS_ENV=production
```

### 🔧 Configurar Certificado

```bash
# Criar diretório para certificado
mkdir -p /home/deploy/my-orders/config/certificates

# Upload do certificado .pfx para o servidor
# Usar SCP ou SFTP
# Exemplo com SCP:
# scp certificado.pfx deploy@SEU_IP:/home/deploy/my-orders/config/certificates/

# Proteger arquivo
chmod 400 /home/deploy/my-orders/config/certificates/certificado.pfx
```

Adicionar ao `.env.production`:

```bash
nano /home/deploy/my-orders/.env.production
```

Adicionar:

```bash
# API Prefeitura - NFS-e Oficial
CERTIFICATE_PATH=/home/deploy/my-orders/config/certificates/certificado.pfx
CERTIFICATE_PASSWORD=SuaSenhaDoCertificado
MUNICIPALITY_CODE=3550308  # Código IBGE da sua cidade
```

### 🔌 Criar Service API

```bash
nano app/services/nfse_api_service.rb
```

Cole:

```ruby
require 'br_nfe'

class NfseApiService
  def initialize(invoice)
    @invoice = invoice
    @company = CompanySetting.instance
  end
  
  def issue
    # Configurar gateway
    gateway = configure_gateway
    
    # Criar RPS (Recibo Provisório de Serviços)
    rps = build_rps
    
    # Enviar para prefeitura
    response = gateway.send_rps(rps)
    
    if response.success?
      process_success(response)
    else
      process_error(response)
    end
    
    response
  rescue => e
    process_exception(e)
  end
  
  def cancel
    return { success: false, error: "Nota não possui número oficial" } unless @invoice.nfse_number.present?
    
    gateway = configure_gateway
    response = gateway.cancel_nfse(@invoice.nfse_number, "Cancelamento solicitado")
    
    if response.success?
      @invoice.update(
        status: :cancelled,
        cancelled_at: Time.current,
        api_status: 'cancelled'
      )
      { success: true, data: response }
    else
      { success: false, error: response.error_messages.join(", ") }
    end
  rescue => e
    { success: false, error: e.message }
  end
  
  def query_status
    return { success: false, error: "Nota não possui RPS" } unless @invoice.rps_number.present?
    
    gateway = configure_gateway
    response = gateway.query_rps(@invoice.rps_number, @invoice.rps_serie)
    
    if response.success?
      update_from_response(response)
      { success: true, data: response }
    else
      { success: false, error: response.error_messages.join(", ") }
    end
  rescue => e
    { success: false, error: e.message }
  end
  
  private
  
  def configure_gateway
    # Configuração específica por cidade
    # Exemplo para São Paulo:
    
    BrNfe.configuration do |config|
      config.gateway = :betha  # ou :ginfes, :simpliss, etc
      config.certificate_path = ENV['CERTIFICATE_PATH']
      config.certificate_password = ENV['CERTIFICATE_PASSWORD']
      
      # Dados da empresa
      config.company_cnpj = @company.cnpj.gsub(/\D/, '')
      config.company_name = @company.company_name
      config.company_municipal_inscription = @company.municipal_inscription
      config.company_address = @company.address
      config.company_number = @company.number
      config.company_district = @company.district
      config.company_city_code = ENV['MUNICIPALITY_CODE']
      config.company_state = @company.state
      config.company_zip_code = @company.zip_code.gsub(/\D/, '')
      config.company_phone = @company.phone.gsub(/\D/, '')
      config.company_email = @company.email
      
      # Ambiente (homologação ou produção)
      config.environment = Rails.env.production? ? :production : :test
    end
    
    BrNfe::ServiceInvoice.new
  end
  
  def build_rps
    {
      numero: generate_rps_number,
      serie: @invoice.serie || "001",
      tipo: 1,  # 1 = RPS normal
      data_emissao: @invoice.issued_at || Time.current,
      natureza_operacao: 1,  # 1 = Tributação no município
      regime_especial_tributacao: 0,  # Regime normal
      optante_simples_nacional: @company.simples?,
      incentivador_cultural: false,
      status: 1,  # 1 = Normal
      
      # Serviços
      servico: {
        valores: {
          valor_servicos: @invoice.total_value,
          valor_deducoes: 0,
          valor_pis: @invoice.pis_value,
          valor_cofins: @invoice.cofins_value,
          valor_inss: 0,
          valor_ir: 0,
          valor_csll: 0,
          iss_retido: false,
          valor_iss: @invoice.iss_value,
          valor_iss_retido: 0,
          outras_retencoes: 0,
          base_calculo: @invoice.total_value,
          aliquota: @invoice.iss_rate,
          valor_liquido_nfse: @invoice.net_value,
          desconto_incondicionado: 0,
          desconto_condicionado: 0
        },
        item_lista_servico: get_service_code,
        codigo_cnae: @company.cnae_code,
        codigo_tributacao_municipio: get_municipal_code,
        discriminacao: @invoice.service_order.description,
        codigo_municipio: ENV['MUNICIPALITY_CODE']
      },
      
      # Tomador (cliente)
      tomador: build_customer_data
    }
  end
  
  def build_customer_data
    cpf_cnpj = @invoice.customer_cpf_cnpj.gsub(/\D/, '')
    
    {
      identificacao_tomador: {
        cpf_cnpj: {
          cpf_cnpj.length == 11 ? :cpf : :cnpj => cpf_cnpj
        },
        inscricao_municipal: nil
      },
      razao_social: @invoice.customer_name,
      endereco: {
        endereco: @invoice.customer_address,
        numero: "S/N",
        complemento: nil,
        bairro: "Centro",
        codigo_municipio: get_city_code(@invoice.customer_city),
        uf: @invoice.customer_state,
        cep: @invoice.customer_zip_code&.gsub(/\D/, '')
      },
      contato: {
        telefone: nil,
        email: @invoice.customer_email
      }
    }
  end
  
  def generate_rps_number
    last_invoice = Invoice.where("rps_number IS NOT NULL")
                          .order(rps_number: :desc)
                          .first
    
    if last_invoice
      (last_invoice.rps_number.to_i + 1).to_s
    else
      "1"
    end
  end
  
  def get_service_code
    # Código do serviço na lista de serviços
    # Exemplo: "01.01" = Análise e desenvolvimento de sistemas
    # Consultar lista: http://www.planalto.gov.br/ccivil_03/leis/lcp/lcp116.htm
    "01.01"
  end
  
  def get_municipal_code
    # Código do serviço no município
    # Varia por cidade
    "010101"
  end
  
  def get_city_code(city_name)
    # Tabela de códigos IBGE
    cities = {
      "São Paulo" => "3550308",
      "Rio de Janeiro" => "3304557",
      "Belo Horizonte" => "3106200",
      "Brasília" => "5300108",
      "Curitiba" => "4106902",
      "Porto Alegre" => "4314902"
    }
    
    cities[city_name] || "0000000"
  end
  
  def process_success(response)
    @invoice.update(
      status: :issued,
      issued_at: Time.current,
      nfse_number: response.numero_nfse,
      verification_code: response.codigo_verificacao,
      xml_file: response.xml,
      xml_response: response.to_json,
      rps_number: response.numero_rps,
      rps_serie: response.serie_rps,
      api_status: 'success'
    )
    
    { success: true, data: response }
  end
  
  def process_error(response)
    errors = response.error_messages.join(", ")
    
    @invoice.update(
      status: :error,
      api_status: 'error',
      api_error: errors
    )
    
    { success: false, error: errors }
  end
  
  def process_exception(exception)
    error_msg = "Erro na comunicação com a API: #{exception.message}"
    
    @invoice.update(
      status: :error,
      api_status: 'exception',
      api_error: error_msg
    )
    
    { success: false, error: error_msg }
  end
  
  def update_from_response(response)
    if response.numero_nfse.present?
      @invoice.update(
        status: :issued,
        nfse_number: response.numero_nfse,
        verification_code: response.codigo_verificacao,
        xml_response: response.to_json,
        api_status: 'success'
      )
    end
  end
end
```

### 🎮 Atualizar Controller

```bash
nano app/controllers/invoices_controller.rb
```

Adicionar método `issue_official`:

```ruby
  # Adicionar antes do private
  
  def issue_official
    @invoice = Invoice.find(params[:id])
    
    unless @invoice.draft? || @invoice.issued?
      redirect_to @invoice, alert: "Nota já foi processada"
      return
    end
    
    service = NfseApiService.new(@invoice)
    result = service.issue
    
    if result[:success]
      redirect_to @invoice, notice: "✅ NFS-e emitida com sucesso! Número: #{@invoice.nfse_number}"
    else
      redirect_to @invoice, alert: "❌ Erro ao emitir: #{result[:error]}"
    end
  end
  
  def query_status_api
    @invoice = Invoice.find(params[:id])
    
    service = NfseApiService.new(@invoice)
    result = service.query_status
    
    if result[:success]
      redirect_to @invoice, notice: "Status atualizado!"
    else
      redirect_to @invoice, alert: "Erro: #{result[:error]}"
    end
  end
```

### 🛣️ Atualizar Rotas

```bash
nano config/routes.rb
```

Adicionar:

```ruby
  resources :invoices do
    member do
      post :issue_official
      post :query_status_api
    end
  end
```

### 🎨 Atualizar View Show

```bash
nano app/views/invoices/show.html.erb
```

Adicionar botões após o botão "Baixar PDF":

```erb
<% if @invoice.draft? %>
  <%= button_to "Emitir NFS-e Oficial", issue_official_invoice_path(@invoice),
      method: :post,
      class: "btn btn-success",
      data: { confirm: "Confirma emissão de NFS-e OFICIAL na prefeitura?" } %>
<% end %>

<% if @invoice.rps_number.present? && @invoice.nfse_number.nil? %>
  <%= button_to "Consultar Status", query_status_api_invoice_path(@invoice),
      method: :post,
      class: "btn btn-info" %>
<% end %>

<% if @invoice.nfse_number.present? %>
  <div class="alert alert-success mt-3">
    <strong>✅ NFS-e Oficial Emitida!</strong><br>
    Número: <%= @invoice.nfse_number %><br>
    Código de Verificação: <%= @invoice.verification_code %>
  </div>
<% end %>
```

---

## 13. MIGRAÇÃO DE DADOS

### 🔄 Estratégia de Migração

**Opção A: Manter PDFs antigos como estão**
- ✅ Mais simples
- ✅ Notas antigas continuam válidas para controle interno
- ✅ Novas notas usam API oficial
- Recomendado: Sim

**Opção B: Reemitir notas antigas via API**
- ❌ Mais complexo
- ❌ Pode causar duplicatas
- ❌ Requer validação manual
- Recomendado: Não

### ✅ Migração Recomendada

```ruby
# Console Rails
bundle exec rails console production

# Marcar notas antigas como "PDF"
Invoice.where(nfse_number: nil).update_all(
  notes: "Nota emitida em PDF (controle interno) antes da integração com API oficial"
)

# A partir de agora, novas notas usarão API
```

---

## 14. TESTES API OFICIAL

### 🧪 Ambiente de Homologação

Antes de produção, testar em homologação:

```bash
# No .env.production
RAILS_ENV=test  # Forçar ambiente de teste

# Testar emissão
# 1. Criar ordem de serviço
# 2. Gerar nota fiscal
# 3. Emitir via API (homologação)
# 4. Verificar no portal da prefeitura
```

### ✅ Checklist de Testes

- [ ] Certificado digital válido
- [ ] Dados da empresa corretos
- [ ] Emissão em homologação OK
- [ ] PDF gerado corretamente
- [ ] Número NFS-e retornado
- [ ] Código de verificação retornado
- [ ] Consulta no portal da prefeitura OK
- [ ] Cancelamento em homologação OK

### 🚀 Produção

Após testes em homologação:

```bash
# Alterar para produção
nano .env.production
# RAILS_ENV=production

# Reiniciar
sudo systemctl restart my-orders
```

**🎉 FASE 2 COMPLETA! NFS-e Oficial funcionando!**

---

## 15. TROUBLESHOOTING

### ❌ Erro: Certificado inválido

```bash
# Verificar certificado
openssl pkcs12 -info -in config/certificates/certificado.pfx
# Digite a senha

# Verificar validade
openssl pkcs12 -in config/certificates/certificado.pfx -nokeys | openssl x509 -noout -dates
```

**Solução:** Renovar certificado digital

### ❌ Erro: Conexão recusada

```bash
# Verificar conectividade
ping api.prefeitura.gov.br

# Verificar firewall
sudo ufw status
```

**Solução:** Liberar porta no firewall

### ❌ Erro: XML inválido

**Solução:** Verificar dados da empresa no CompanySetting

---

## 16. MANUTENÇÃO

### 📅 Rotinas Periódicas

**Diário:**
```bash
# Ver logs
tail -100 /home/deploy/my-orders/log/production.log
```

**Semanal:**
```bash
# Verificar espaço em disco
df -h

# Backup manual
pg_dump -U deploy service_orders_production > backup_$(date +%Y%m%d).sql
```

**Mensal:**
```bash
# Limpar logs antigos
cd /home/deploy/my-orders
rm log/*.log.1 log/*.log.2 2>/dev/null
```

**Anual:**
```bash
# Renovar certificado digital
# Comprar novo certificado 30 dias antes do vencimento
# Upload e atualizar .env.production
```

---

## 17. CUSTOS DETALHADOS

### 💰 Comparação Final

#### Opção 1: PDF Básico (Fase 1)
```
VPS 2GB:         R$ 60/mês × 12 = R$  720/ano
Backups:         R$  6/mês × 12 = R$   72/ano
─────────────────────────────────────────────
TOTAL ANO 1:                      R$  792/ano
```

#### Opção 2: API Direta (Fase 1 + 2)
```
Fase 1 (3 meses PDF):
  VPS + Backups:    R$ 66/mês × 3 = R$  198

Fase 2 (9 meses API):
  VPS + Backups:    R$ 66/mês × 9 = R$  594
  Certificado:      R$ 250/ano     = R$  250
─────────────────────────────────────────────
TOTAL ANO 1:                        R$ 1.042/ano
```

#### Opção 3: NFE.io (hipotético)
```
VPS + Backups:    R$  66/mês × 12 = R$   792/ano
NFE.io Base:      R$ 179/mês × 12 = R$ 2.148/ano
Certificado:      R$ 250/ano       = R$   250/ano
─────────────────────────────────────────────
TOTAL ANO 1:                        R$ 3.190/ano
```

### 📊 Economia vs NFE.io

**Fase 1 (PDF):** R$ 3.190 - R$ 792 = **R$ 2.398 economizados/ano**

**Fase 2 (API):** R$ 3.190 - R$ 1.042 = **R$ 2.148 economizados/ano**

---

## 🎉 CONCLUSÃO

### ✅ O que você conseguiu

**Fase 1 (hoje):**
- ✅ Sistema completo em produção
- ✅ Nota Fiscal PDF funcionando
- ✅ Custo baixo: R$ 66/mês
- ✅ Validação com clientes reais

**Fase 2 (quando precisar):**
- ✅ NFS-e oficial com validade fiscal
- ✅ Economia de R$ 2.148/ano vs NFE.io
- ✅ Controle total da solução
- ✅ Sem dependência de terceiros

### 🎯 Próximos Passos

1. **Hoje:** Finalizar Fase 1
2. **Próximos 1-3 meses:** Usar e validar com clientes
3. **Quando precisar NFS-e:** Implementar Fase 2
4. **Manter:** Rotinas de manutenção

### 💡 Dica Final

**Não tenha pressa para implementar Fase 2!**

Use a Fase 1 (PDF) o máximo que puder. Economize R$ 2.398/ano enquanto valida o sistema. 

Só migre para API Direta quando:
- Clientes pedirem NFS-e oficial
- Volume justificar (> 50 notas/mês)
- Tiver tempo para implementar

---

**🚀 BOA SORTE COM SEU DEPLOY! 🚀**

*Última atualização: 2024-02-26*
*Autor: Claude Code Assistant*
*Licença: MIT*
