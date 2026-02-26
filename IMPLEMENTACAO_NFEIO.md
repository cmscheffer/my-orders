# 🚀 IMPLEMENTAÇÃO COMPLETA - NFE.io

## 📋 VISÃO GERAL

Este guia implementa emissão de NFS-e com validade fiscal usando a API do NFE.io.

**Tempo de implementação:** 2-3 horas  
**Custo:** R$ 20-200/mês (conforme volume)  
**Validade fiscal:** ✅ SIM (oficial)

---

## 🎯 O QUE SERÁ IMPLEMENTADO

✅ **Integração completa com NFE.io**  
✅ **Emissão de NFS-e oficial**  
✅ **Consulta de notas emitidas**  
✅ **Cancelamento de notas**  
✅ **Webhooks para atualizações automáticas**  
✅ **PDF com dados oficiais**  
✅ **Gestão completa de notas**

---

## 📦 PASSO 1: Cadastro no NFE.io

### **1.1 Criar Conta**

1. Acesse: https://nfe.io
2. Clique em "Experimente Grátis"
3. Preencha dados da empresa:
   - Nome/Razão Social
   - CNPJ
   - Email
   - Senha

### **1.2 Planos Disponíveis**

| Plano | Notas/Mês | Preço |
|-------|-----------|-------|
| **Starter** | 100 | R$ 20/mês |
| **Básico** | 500 | R$ 50/mês |
| **Pro** | 2.000 | R$ 120/mês |
| **Enterprise** | 10.000+ | R$ 300+/mês |

**Teste grátis:** 7 dias (até 10 notas)

### **1.3 Obter Credenciais**

Após criar conta:

1. Acesse **Dashboard**
2. Vá em **Configurações** → **Integrações**
3. Copie suas credenciais:
   - **API Key** (ex: `abc123def456...`)
   - **Company ID** (ex: `comp_abc123...`)

**Guarde essas credenciais com segurança!**

### **1.4 Configurar Empresa**

No dashboard do NFE.io:

1. **Dados da Empresa:**
   - Razão Social
   - CNPJ
   - Inscrição Municipal
   - Endereço completo
   - Telefone/Email

2. **Certificado Digital:**
   - Upload do certificado A1 (.pfx)
   - Senha do certificado

3. **Configurações Fiscais:**
   - Regime tributário
   - Código do serviço
   - Alíquota ISS padrão

---

## 🔧 PASSO 2: Instalar Gems

### **2.1 Adicionar ao Gemfile**

```ruby
# Gemfile

# NFE.io API client
gem 'httparty', '~> 0.21'  # Cliente HTTP
gem 'dotenv-rails', '~> 2.8'  # Variáveis de ambiente
```

### **2.2 Instalar**

```bash
cd /home/user/webapp
bundle install
```

---

## 🗄️ PASSO 3: Database (Migration)

### **3.1 Criar Migration**

```bash
rails generate migration CreateInvoices
```

### **3.2 Editar Migration**

Editar `db/migrate/XXXXXXXXX_create_invoices.rb`:

```ruby
class CreateInvoices < ActiveRecord::Migration[7.1]
  def change
    create_table :invoices do |t|
      # Relacionamento
      t.references :service_order, null: false, foreign_key: true
      
      # Identificação interna
      t.string :invoice_number, null: false
      t.string :serie, default: "001"
      t.datetime :issued_at
      t.datetime :cancelled_at
      t.integer :status, default: 0  # 0=draft, 1=processing, 2=issued, 3=error, 4=cancelled
      
      # Valores (cópia do service_order)
      t.decimal :service_value, precision: 10, scale: 2
      t.decimal :total_value, precision: 10, scale: 2
      
      # Impostos calculados
      t.decimal :iss_rate, precision: 5, scale: 2, default: 5.00
      t.decimal :iss_value, precision: 10, scale: 2
      t.decimal :pis_value, precision: 10, scale: 2
      t.decimal :cofins_value, precision: 10, scale: 2
      t.decimal :net_value, precision: 10, scale: 2
      
      # Dados do tomador (cliente) - snapshot
      t.string :customer_name
      t.string :customer_cpf_cnpj
      t.string :customer_email
      t.string :customer_address
      t.string :customer_city
      t.string :customer_state
      t.string :customer_zip_code
      
      # NFE.io Integration
      t.string :nfeio_id              # ID da nota no NFE.io
      t.string :nfeio_status          # Status retornado pelo NFE.io
      t.string :official_number       # Número oficial da prefeitura
      t.string :verification_code     # Código de verificação
      t.string :pdf_url               # URL do PDF no NFE.io
      t.text :nfeio_response          # JSON completo da resposta
      t.text :error_message           # Mensagem de erro (se houver)
      
      # Observações
      t.text :notes
      
      t.timestamps
    end
    
    # Índices
    add_index :invoices, :invoice_number, unique: true
    add_index :invoices, :status
    add_index :invoices, :nfeio_id, unique: true
    add_index :invoices, :official_number
  end
end
```

### **3.3 Executar Migration**

```bash
rails db:migrate
```

---

## ⚙️ PASSO 4: Configuração

### **4.1 Criar arquivo .env**

```bash
# .env (na raiz do projeto)

# NFE.io Credentials
NFEIO_API_KEY=sua_api_key_aqui
NFEIO_COMPANY_ID=seu_company_id_aqui

# Ambiente (development ou production)
NFEIO_ENVIRONMENT=development

# Webhook secret (gere um: rails secret | head -c 32)
NFEIO_WEBHOOK_SECRET=seu_webhook_secret_aqui
```

**⚠️ IMPORTANTE:** Adicione `.env` ao `.gitignore`:

```bash
echo ".env" >> .gitignore
```

### **4.2 Criar Initializer**

Criar `config/initializers/nfeio.rb`:

```ruby
# config/initializers/nfeio.rb

NFEIO_CONFIG = {
  api_key: ENV['NFEIO_API_KEY'],
  company_id: ENV['NFEIO_COMPANY_ID'],
  environment: ENV['NFEIO_ENVIRONMENT'] || 'development',
  webhook_secret: ENV['NFEIO_WEBHOOK_SECRET'],
  
  # URLs da API
  api_url: {
    development: 'https://api.nfe.io',
    production: 'https://api.nfe.io'
  }
}.freeze

# Validar configuração
if Rails.env.production?
  raise "NFE.io API Key não configurada!" if NFEIO_CONFIG[:api_key].blank?
  raise "NFE.io Company ID não configurado!" if NFEIO_CONFIG[:company_id].blank?
end
```

---

## 📝 PASSO 5: Model Invoice

Criar `app/models/invoice.rb`:

```ruby
# app/models/invoice.rb

class Invoice < ApplicationRecord
  belongs_to :service_order
  
  # Enums
  enum status: {
    draft: 0,           # Rascunho (não enviado)
    processing: 1,      # Processando no NFE.io
    issued: 2,          # Emitida com sucesso
    error: 3,           # Erro na emissão
    cancelled: 4        # Cancelada
  }
  
  # Validações
  validates :invoice_number, presence: true, uniqueness: true
  validates :serie, presence: true
  validates :total_value, numericality: { greater_than: 0 }
  validates :iss_rate, numericality: { 
    greater_than_or_equal_to: 0, 
    less_than_or_equal_to: 100 
  }
  validates :customer_name, presence: true
  validates :customer_cpf_cnpj, presence: true
  
  # Callbacks
  before_validation :generate_invoice_number, on: :create
  before_validation :copy_service_order_data, on: :create
  before_save :calculate_taxes
  
  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :current_year, -> { where("YEAR(created_at) = ?", Date.current.year) }
  scope :with_nfeio_id, -> { where.not(nfeio_id: nil) }
  
  # Métodos de negócio
  def can_be_issued?
    draft? && nfeio_id.nil? && total_value.present? && total_value > 0
  end
  
  def can_be_cancelled?
    issued? && cancelled_at.nil? && nfeio_id.present?
  end
  
  def mark_as_issued!(response_data)
    update!(
      status: :issued,
      issued_at: Time.current,
      nfeio_id: response_data['id'],
      nfeio_status: response_data['status'],
      official_number: response_data['number'],
      verification_code: response_data['verificationCode'],
      pdf_url: response_data['pdfUrl'],
      nfeio_response: response_data.to_json
    )
  end
  
  def mark_as_error!(error_msg)
    update!(
      status: :error,
      error_message: error_msg
    )
  end
  
  def mark_as_cancelled!(response_data = nil)
    update!(
      status: :cancelled,
      cancelled_at: Time.current,
      nfeio_status: response_data ? response_data['status'] : 'cancelled',
      nfeio_response: response_data ? response_data.to_json : nfeio_response
    )
  end
  
  # Formatações
  def formatted_invoice_number
    "NFS-e #{serie}-#{invoice_number}"
  end
  
  def formatted_total_value
    "R$ #{format('%.2f', total_value || 0)}".gsub('.', ',')
  end
  
  def formatted_iss_value
    "R$ #{format('%.2f', iss_value || 0)}".gsub('.', ',')
  end
  
  def formatted_net_value
    "R$ #{format('%.2f', net_value || 0)}".gsub('.', ',')
  end
  
  def formatted_cpf_cnpj
    return '' unless customer_cpf_cnpj.present?
    
    numbers = customer_cpf_cnpj.gsub(/\D/, '')
    
    if numbers.length == 11
      # CPF: 123.456.789-01
      "#{numbers[0..2]}.#{numbers[3..5]}.#{numbers[6..8]}-#{numbers[9..10]}"
    elsif numbers.length == 14
      # CNPJ: 12.345.678/0001-90
      "#{numbers[0..1]}.#{numbers[2..4]}.#{numbers[5..7]}/#{numbers[8..11]}-#{numbers[12..13]}"
    else
      customer_cpf_cnpj
    end
  end
  
  def status_badge_class
    case status
    when "draft"
      "bg-secondary"
    when "processing"
      "bg-info"
    when "issued"
      "bg-success"
    when "error"
      "bg-danger"
    when "cancelled"
      "bg-warning"
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
    
    self.service_value = service_order.service_value
    self.total_value = service_order.total_value
    self.customer_name = service_order.customer_name
    self.customer_email = service_order.customer_email
    # TODO: Adicionar mais campos quando disponíveis no ServiceOrder
  end
  
  def calculate_taxes
    return unless total_value
    
    self.iss_rate ||= 5.00
    self.iss_value = (total_value * (iss_rate / 100.0)).round(2)
    self.pis_value = (total_value * 0.0065).round(2)
    self.cofins_value = (total_value * 0.03).round(2)
    self.net_value = (total_value - iss_value - pis_value - cofins_value).round(2)
  end
end
```

---

## 🔌 PASSO 6: Service NFE.io

Criar `app/services/nfeio_service.rb`:

```ruby
# app/services/nfeio_service.rb

require 'httparty'

class NfeioService
  include HTTParty
  
  base_uri 'https://api.nfe.io/v1'
  
  def initialize
    @api_key = NFEIO_CONFIG[:api_key]
    @company_id = NFEIO_CONFIG[:company_id]
    
    raise "NFE.io não configurado" if @api_key.blank? || @company_id.blank?
  end
  
  # Emitir nota fiscal
  def issue_invoice(invoice)
    payload = build_payload(invoice)
    
    response = self.class.post(
      "/companies/#{@company_id}/serviceinvoices",
      headers: headers,
      body: payload.to_json
    )
    
    handle_response(response)
  end
  
  # Consultar nota fiscal
  def get_invoice(nfeio_id)
    response = self.class.get(
      "/companies/#{@company_id}/serviceinvoices/#{nfeio_id}",
      headers: headers
    )
    
    handle_response(response)
  end
  
  # Cancelar nota fiscal
  def cancel_invoice(nfeio_id)
    response = self.class.delete(
      "/companies/#{@company_id}/serviceinvoices/#{nfeio_id}",
      headers: headers
    )
    
    handle_response(response)
  end
  
  # Baixar PDF
  def download_pdf(nfeio_id)
    response = self.class.get(
      "/companies/#{@company_id}/serviceinvoices/#{nfeio_id}/pdf",
      headers: headers
    )
    
    response.body if response.success?
  end
  
  private
  
  def headers
    {
      'Authorization' => @api_key,
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  end
  
  def build_payload(invoice)
    company = CompanySetting.instance
    
    {
      cityServiceCode: "01.01",  # Código do serviço (consultar tabela)
      description: invoice.service_order.description,
      servicesAmount: invoice.total_value,
      
      borrower: {
        name: invoice.customer_name,
        email: invoice.customer_email,
        federalTaxNumber: invoice.customer_cpf_cnpj&.gsub(/\D/, ''),
        address: {
          country: "BRA",
          postalCode: invoice.customer_zip_code&.gsub(/\D/, ''),
          street: invoice.customer_address,
          number: "S/N",
          additionalInformation: "",
          district: "Centro",
          city: {
            code: get_ibge_code(invoice.customer_city),
            name: invoice.customer_city
          },
          state: invoice.customer_state
        }
      }
    }
  end
  
  def handle_response(response)
    case response.code
    when 200, 201
      {
        success: true,
        data: JSON.parse(response.body)
      }
    when 400, 422
      error_data = JSON.parse(response.body) rescue {}
      {
        success: false,
        error: error_data['message'] || 'Erro de validação',
        details: error_data
      }
    when 401
      {
        success: false,
        error: 'API Key inválida ou expirada'
      }
    when 404
      {
        success: false,
        error: 'Nota fiscal não encontrada'
      }
    else
      {
        success: false,
        error: "Erro HTTP #{response.code}: #{response.message}"
      }
    end
  rescue => e
    {
      success: false,
      error: "Erro na requisição: #{e.message}"
    }
  end
  
  def get_ibge_code(city_name)
    # Tabela simplificada (adicionar mais cidades conforme necessário)
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
end
```

---

## 🎮 PASSO 7: Controller

Criar `app/controllers/invoices_controller.rb`:

```ruby
# app/controllers/invoices_controller.rb

class InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_service_order, only: [:new, :create]
  before_action :set_invoice, only: [:show, :edit, :update, :issue, :cancel, :download_pdf]
  before_action :authorize_admin!, except: [:show, :download_pdf]
  
  def index
    @invoices = Invoice.includes(:service_order)
                      .recent
                      .page(params[:page])
                      .per(15)
    
    @invoices = @invoices.by_status(params[:status]) if params[:status].present?
  end
  
  def show
    authorize_invoice_access!
  end
  
  def new
    unless @service_order.can_generate_invoice?
      redirect_to @service_order, alert: "Ordem de serviço não pode gerar nota fiscal"
      return
    end
    
    @invoice = @service_order.build_invoice(
      serie: "001",
      iss_rate: 5.00
    )
  end
  
  def create
    @invoice = @service_order.build_invoice(invoice_params)
    @invoice.status = :draft
    
    if @invoice.save
      redirect_to @invoice, notice: "Nota fiscal criada! Clique em 'Emitir' para enviar ao NFE.io"
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
  
  # Emitir nota fiscal no NFE.io
  def issue
    unless @invoice.can_be_issued?
      redirect_to @invoice, alert: "Nota fiscal não pode ser emitida"
      return
    end
    
    @invoice.update(status: :processing)
    
    service = NfeioService.new
    result = service.issue_invoice(@invoice)
    
    if result[:success]
      @invoice.mark_as_issued!(result[:data])
      redirect_to @invoice, notice: "✅ NFS-e emitida com sucesso! Número oficial: #{@invoice.official_number}"
    else
      @invoice.mark_as_error!(result[:error])
      redirect_to @invoice, alert: "❌ Erro ao emitir: #{result[:error]}"
    end
  rescue => e
    @invoice.mark_as_error!(e.message)
    redirect_to @invoice, alert: "❌ Erro inesperado: #{e.message}"
  end
  
  # Cancelar nota fiscal
  def cancel
    unless @invoice.can_be_cancelled?
      redirect_to @invoice, alert: "Nota fiscal não pode ser cancelada"
      return
    end
    
    service = NfeioService.new
    result = service.cancel_invoice(@invoice.nfeio_id)
    
    if result[:success]
      @invoice.mark_as_cancelled!(result[:data])
      redirect_to @invoice, notice: "✅ NFS-e cancelada com sucesso!"
    else
      redirect_to @invoice, alert: "❌ Erro ao cancelar: #{result[:error]}"
    end
  rescue => e
    redirect_to @invoice, alert: "❌ Erro inesperado: #{e.message}"
  end
  
  # Baixar PDF oficial
  def download_pdf
    authorize_invoice_access!
    
    if @invoice.pdf_url.present?
      redirect_to @invoice.pdf_url, allow_other_host: true
    else
      redirect_to @invoice, alert: "PDF não disponível"
    end
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
  
  def authorize_admin!
    unless current_user.admin?
      redirect_to root_path, alert: "Acesso negado"
    end
  end
  
  def authorize_invoice_access!
    unless current_user.admin? || @invoice.service_order.user_id == current_user.id
      redirect_to root_path, alert: "Acesso negado"
    end
  end
end
```

---

## 🛣️ PASSO 8: Routes

Adicionar em `config/routes.rb`:

```ruby
# config/routes.rb

Rails.application.routes.draw do
  # ... rotas existentes ...
  
  # Invoices (Notas Fiscais)
  resources :invoices, only: [:index, :show, :edit, :update] do
    member do
      post :issue           # Emitir no NFE.io
      delete :cancel        # Cancelar
      get :download_pdf     # Baixar PDF oficial
    end
  end
  
  # Gerar nota a partir de ordem de serviço
  resources :service_orders do
    resources :invoices, only: [:new, :create]
  end
  
  # Webhooks NFE.io
  post '/webhooks/nfeio', to: 'webhooks#nfeio'
  
  # ... resto das rotas ...
end
```

---

## 🎨 PASSO 9: Views

### **9.1 Index** (`app/views/invoices/index.html.erb`)

```erb
<div class="container mt-4">
  <div class="d-flex justify-content-between align-items-center mb-4">
    <h1><i class="bi bi-receipt"></i> Notas Fiscais NFE.io</h1>
  </div>
  
  <!-- Filtros -->
  <div class="card mb-4">
    <div class="card-body">
      <%= form_with url: invoices_path, method: :get, local: true, class: "row g-3" do %>
        <div class="col-md-4">
          <%= select_tag :status, 
              options_for_select([
                ["Todos os Status", ""],
                ["Rascunho", "draft"],
                ["Processando", "processing"],
                ["Emitida", "issued"],
                ["Erro", "error"],
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
                <th>Criação</th>
                <th>Valor</th>
                <th>Status</th>
                <th>Nº Oficial</th>
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
                  <td><%= l(invoice.created_at, format: :short) %></td>
                  <td><strong><%= invoice.formatted_total_value %></strong></td>
                  <td>
                    <span class="badge <%= invoice.status_badge_class %>">
                      <%= invoice.status.humanize %>
                    </span>
                  </td>
                  <td>
                    <% if invoice.official_number.present? %>
                      <strong><%= invoice.official_number %></strong>
                    <% else %>
                      <span class="text-muted">—</span>
                    <% end %>
                  </td>
                  <td>
                    <%= link_to "Ver", invoice, class: "btn btn-sm btn-info" %>
                    
                    <% if invoice.pdf_url.present? %>
                      <%= link_to "PDF", download_pdf_invoice_path(invoice), 
                          class: "btn btn-sm btn-danger", target: "_blank" %>
                    <% end %>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
        
        <div class="mt-3">
          <%= paginate @invoices, theme: 'twitter-bootstrap-5' %>
        </div>
      <% else %>
        <p class="text-center text-muted">Nenhuma nota fiscal encontrada.</p>
      <% end %>
    </div>
  </div>
</div>
```

### **9.2 Show** (continua no próximo arquivo...)

---

## 📊 CONTINUAÇÃO NO PRÓXIMO ARQUIVO

Este guia é muito extenso. Vou criar arquivos adicionais:

1. ✅ **IMPLEMENTACAO_NFEIO.md** (este arquivo) - Parte 1
2. ⏳ **IMPLEMENTACAO_NFEIO_PARTE2.md** - Views e Webhooks
3. ⏳ **IMPLEMENTACAO_NFEIO_TESTING.md** - Testes e Deploy

**Total:** ~100KB de documentação completa!

---

**Continue lendo:** `IMPLEMENTACAO_NFEIO_PARTE2.md`
