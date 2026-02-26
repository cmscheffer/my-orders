# 📄 IMPLEMENTAÇÃO DE NOTA FISCAL DE SERVIÇO (NFS-e)

## 📋 ÍNDICE

1. [Visão Geral](#visão-geral)
2. [Tipos de Implementação](#tipos-de-implementação)
3. [Implementação Básica (PDF)](#implementação-básica-pdf)
4. [Implementação Avançada (API Prefeitura)](#implementação-avançada-api-prefeitura)
5. [Passo a Passo Completo](#passo-a-passo-completo)
6. [Código Pronto para Usar](#código-pronto-para-usar)
7. [Integrações Disponíveis](#integrações-disponíveis)

---

## 🎯 VISÃO GERAL

### O Que é NFS-e?

**Nota Fiscal de Serviço Eletrônica (NFS-e)** é um documento fiscal digital que comprova a prestação de serviços e permite o recolhimento do **ISS (Imposto Sobre Serviços)**.

### Requisitos Legais

Para emitir NFS-e oficialmente, você precisa:
- ✅ **CNPJ** da empresa prestadora
- ✅ **Inscrição Municipal** na prefeitura
- ✅ **Cadastro no sistema** da prefeitura local
- ✅ **Certificado Digital A1 ou A3** (algumas prefeituras)
- ✅ **Integração com API** da prefeitura (varia por cidade)

### Duas Abordagens

| Abordagem | Complexidade | Validade Fiscal | Custo | Recomendado Para |
|-----------|-------------|----------------|-------|------------------|
| **Básica (PDF)** | Baixa ⭐ | ❌ Não oficial | Grátis | Controle interno |
| **Avançada (API)** | Alta ⭐⭐⭐ | ✅ Oficial | Variável | Emissão legal |

---

## 🔰 TIPOS DE IMPLEMENTAÇÃO

### 1️⃣ **Implementação BÁSICA (Recomendada para Começar)**

**O que faz:**
- ✅ Gera PDF com layout profissional de nota fiscal
- ✅ Inclui todos os dados necessários (empresa, cliente, serviços)
- ✅ Calcula impostos (ISS, PIS, COFINS, etc.)
- ✅ Numeração sequencial automática
- ✅ Controle de status (emitida, cancelada)
- ❌ **NÃO tem validade fiscal oficial**

**Uso ideal:**
- Controle interno da empresa
- Orçamentos e propostas
- Recibos de serviço
- Preparação para futura emissão oficial

**Vantagens:**
- ✅ Implementação rápida (2-3 horas)
- ✅ Não requer certificado digital
- ✅ Funciona em qualquer cidade
- ✅ Custo zero

**Desvantagens:**
- ❌ Não tem validade fiscal
- ❌ Não envia para prefeitura
- ❌ Cliente não pode deduzir imposto

---

### 2️⃣ **Implementação AVANÇADA (Integração com Prefeitura)**

**O que faz:**
- ✅ Integra com API da prefeitura local
- ✅ Envia XML para validação oficial
- ✅ Recebe número oficial da prefeitura
- ✅ Gera PDF com QR Code e autenticação
- ✅ **TEM validade fiscal oficial**

**Uso ideal:**
- Emissão legal de notas fiscais
- Empresas que precisam recolher ISS
- Clientes pessoa jurídica (necessário para dedução)

**Vantagens:**
- ✅ Validade fiscal completa
- ✅ Cliente pode deduzir imposto
- ✅ Conformidade legal

**Desvantagens:**
- ❌ Implementação complexa (1-2 semanas)
- ❌ Requer certificado digital ($150-300/ano)
- ❌ Cada cidade tem API diferente
- ❌ Pode ter custo mensal (alguns sistemas)

---

## 🚀 IMPLEMENTAÇÃO BÁSICA (PDF)

### Arquitetura

```
ServiceOrder (1) ---< (1) Invoice (Nota Fiscal)
                          |
                          |-- número sequencial
                          |-- data emissão
                          |-- valores e impostos
                          |-- status (emitida/cancelada)
                          |-- PDF generator
```

### Database Schema

```ruby
# Nova tabela: invoices
create_table :invoices do |t|
  t.references :service_order, null: false, foreign_key: true
  
  # Identificação
  t.string :invoice_number, null: false  # "0001", "0002", etc.
  t.string :serie, default: "001"        # Série da nota
  
  # Datas
  t.datetime :issued_at, null: false     # Data de emissão
  t.datetime :cancelled_at               # Data de cancelamento
  
  # Status
  t.integer :status, default: 0          # 0=draft, 1=issued, 2=cancelled
  
  # Valores (cópia do service_order para histórico)
  t.decimal :service_value, precision: 10, scale: 2
  t.decimal :parts_value, precision: 10, scale: 2
  t.decimal :total_value, precision: 10, scale: 2
  
  # Impostos (calculados)
  t.decimal :iss_rate, precision: 5, scale: 2       # Ex: 5.00 (5%)
  t.decimal :iss_value, precision: 10, scale: 2
  t.decimal :pis_value, precision: 10, scale: 2
  t.decimal :cofins_value, precision: 10, scale: 2
  t.decimal :net_value, precision: 10, scale: 2    # Valor líquido
  
  # Dados do tomador (cliente) - snapshot
  t.string :customer_name
  t.string :customer_cpf_cnpj
  t.string :customer_address
  t.string :customer_city
  t.string :customer_state
  t.string :customer_zip_code
  
  # Observações
  t.text :notes
  
  t.timestamps
end

# Índices
add_index :invoices, :invoice_number, unique: true
add_index :invoices, :status
add_index :invoices, :issued_at
```

---

## 📝 PASSO A PASSO COMPLETO

### **PASSO 1: Criar Migration**

```bash
cd /home/user/webapp
rails generate migration CreateInvoices
```

Edite o arquivo gerado em `db/migrate/`:

```ruby
class CreateInvoices < ActiveRecord::Migration[7.1]
  def change
    create_table :invoices do |t|
      t.references :service_order, null: false, foreign_key: true
      
      # Identificação
      t.string :invoice_number, null: false
      t.string :serie, default: "001"
      
      # Datas
      t.datetime :issued_at, null: false
      t.datetime :cancelled_at
      
      # Status
      t.integer :status, default: 0
      
      # Valores
      t.decimal :service_value, precision: 10, scale: 2
      t.decimal :parts_value, precision: 10, scale: 2
      t.decimal :total_value, precision: 10, scale: 2
      
      # Impostos
      t.decimal :iss_rate, precision: 5, scale: 2, default: 5.00
      t.decimal :iss_value, precision: 10, scale: 2
      t.decimal :pis_value, precision: 10, scale: 2
      t.decimal :cofins_value, precision: 10, scale: 2
      t.decimal :net_value, precision: 10, scale: 2
      
      # Dados do tomador (snapshot)
      t.string :customer_name
      t.string :customer_cpf_cnpj
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
    add_index :invoices, :issued_at
  end
end
```

Executar migration:

```bash
rails db:migrate
```

---

### **PASSO 2: Criar Model Invoice**

Criar arquivo `app/models/invoice.rb`:

```ruby
class Invoice < ApplicationRecord
  belongs_to :service_order
  
  # Enums
  enum status: {
    draft: 0,       # Rascunho
    issued: 1,      # Emitida
    cancelled: 2    # Cancelada
  }
  
  # Validações
  validates :invoice_number, presence: true, uniqueness: true
  validates :serie, presence: true
  validates :issued_at, presence: true
  validates :total_value, numericality: { greater_than: 0 }
  validates :iss_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  
  # Callbacks
  before_validation :generate_invoice_number, on: :create
  before_validation :copy_service_order_data, on: :create
  before_save :calculate_taxes
  
  # Scopes
  scope :recent, -> { order(issued_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :current_year, -> { where("YEAR(issued_at) = ?", Date.current.year) }
  
  # Métodos de negócio
  def can_be_cancelled?
    issued? && cancelled_at.nil?
  end
  
  def cancel!
    return false unless can_be_cancelled?
    update(status: :cancelled, cancelled_at: Time.current)
  end
  
  def issue!
    return false unless draft?
    update(status: :issued, issued_at: Time.current)
  end
  
  # Formatações
  def formatted_invoice_number
    "NFS-e #{serie}-#{invoice_number}"
  end
  
  def formatted_total_value
    "R$ #{format('%.2f', total_value || 0)}"
  end
  
  def formatted_iss_value
    "R$ #{format('%.2f', iss_value || 0)}"
  end
  
  def formatted_net_value
    "R$ #{format('%.2f', net_value || 0)}"
  end
  
  def status_badge_class
    case status
    when "draft"
      "bg-secondary"
    when "issued"
      "bg-success"
    when "cancelled"
      "bg-danger"
    end
  end
  
  private
  
  def generate_invoice_number
    return if invoice_number.present?
    
    # Busca o último número da série atual no ano corrente
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
    
    # Copia valores
    self.service_value = service_order.service_value
    self.parts_value = service_order.parts_value
    self.total_value = service_order.total_value
    
    # Copia dados do cliente (criar Customer model separado seria ideal)
    self.customer_name = service_order.customer_name
    # TODO: Adicionar campos de CPF/CNPJ no ServiceOrder ou Customer
  end
  
  def calculate_taxes
    return unless total_value
    
    # ISS (Imposto Sobre Serviços) - varia de 2% a 5% por município
    self.iss_rate ||= 5.00
    self.iss_value = (total_value * (iss_rate / 100.0)).round(2)
    
    # PIS (0.65%) e COFINS (3%) - regime normal
    self.pis_value = (total_value * 0.0065).round(2)
    self.cofins_value = (total_value * 0.03).round(2)
    
    # Valor líquido (total - impostos)
    self.net_value = (total_value - iss_value - pis_value - cofins_value).round(2)
  end
end
```

---

### **PASSO 3: Atualizar ServiceOrder Model**

Adicionar associação em `app/models/service_order.rb`:

```ruby
class ServiceOrder < ApplicationRecord
  # ... código existente ...
  
  # Adicionar esta linha após outros belongs_to/has_many:
  has_one :invoice, dependent: :restrict_with_error
  
  # Adicionar métodos:
  def has_invoice?
    invoice.present?
  end
  
  def can_generate_invoice?
    completed? && !has_invoice? && total_value.present? && total_value > 0
  end
end
```

---

### **PASSO 4: Criar Controller**

Criar `app/controllers/invoices_controller.rb`:

```ruby
class InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_service_order, only: [:new, :create]
  before_action :set_invoice, only: [:show, :edit, :update, :cancel, :pdf]
  before_action :authorize_admin!, except: [:show, :pdf]
  
  def index
    @invoices = Invoice.includes(:service_order)
                      .recent
                      .page(params[:page])
                      .per(15)
    
    # Filtros
    @invoices = @invoices.by_status(params[:status]) if params[:status].present?
  end
  
  def show
    # Autorização: admin ou dono da OS
    unless current_user.admin? || @invoice.service_order.user_id == current_user.id
      redirect_to root_path, alert: "Acesso negado"
    end
  end
  
  def new
    unless @service_order.can_generate_invoice?
      redirect_to @service_order, alert: "Ordem de serviço não pode gerar nota fiscal"
      return
    end
    
    @invoice = @service_order.build_invoice(
      issued_at: Time.current,
      serie: "001"
    )
  end
  
  def create
    @invoice = @service_order.build_invoice(invoice_params)
    @invoice.status = :issued
    
    if @invoice.save
      redirect_to @invoice, notice: "Nota fiscal emitida com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    unless @invoice.draft?
      redirect_to @invoice, alert: "Nota fiscal emitida não pode ser editada"
    end
  end
  
  def update
    if @invoice.draft? && @invoice.update(invoice_params)
      redirect_to @invoice, notice: "Nota fiscal atualizada com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def cancel
    if @invoice.cancel!
      redirect_to @invoice, notice: "Nota fiscal cancelada com sucesso!"
    else
      redirect_to @invoice, alert: "Não foi possível cancelar a nota fiscal"
    end
  end
  
  def pdf
    pdf_generator = InvoicePdfGenerator.new(@invoice)
    
    send_data pdf_generator.render,
              filename: "nota_fiscal_#{@invoice.invoice_number}.pdf",
              type: "application/pdf",
              disposition: "inline"
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
      :customer_address,
      :customer_city,
      :customer_state,
      :customer_zip_code,
      :notes
    )
  end
  
  def authorize_admin!
    unless current_user.admin?
      redirect_to root_path, alert: "Acesso negado. Apenas administradores."
    end
  end
end
```

---

### **PASSO 5: Criar Service para PDF**

Criar `app/services/invoice_pdf_generator.rb`:

```ruby
require 'prawn'
require 'prawn/table'

class InvoicePdfGenerator
  def initialize(invoice)
    @invoice = invoice
    @service_order = invoice.service_order
    @company = CompanySetting.instance
  end
  
  def render
    pdf = Prawn::Document.new(page_size: 'A4', margin: 40)
    
    # Header com logo e dados da empresa
    add_header(pdf)
    
    # Título e identificação da nota
    add_title(pdf)
    
    # Dados do prestador (empresa)
    add_provider_data(pdf)
    
    # Dados do tomador (cliente)
    add_customer_data(pdf)
    
    # Descrição do serviço
    add_service_description(pdf)
    
    # Valores e impostos
    add_values_table(pdf)
    
    # Observações
    add_notes(pdf) if @invoice.notes.present?
    
    # Footer
    add_footer(pdf)
    
    pdf.render
  end
  
  private
  
  def add_header(pdf)
    if @company.has_logo?
      # Logo
      image_data = StringIO.new(@company.logo_data)
      pdf.image image_data, height: 50, position: :left
    end
    
    pdf.move_down 10
    
    # Dados da empresa
    pdf.text @company.company_name || "Nome da Empresa", size: 16, style: :bold
    pdf.text "CNPJ: #{@company.formatted_cnpj}" if @company.cnpj.present?
    pdf.text @company.address if @company.address.present?
    pdf.text "#{@company.city} - #{@company.state}" if @company.city.present?
    
    pdf.move_down 20
    pdf.stroke_horizontal_rule
    pdf.move_down 20
  end
  
  def add_title(pdf)
    pdf.text "NOTA FISCAL DE SERVIÇO", size: 18, style: :bold, align: :center
    pdf.move_down 5
    pdf.text @invoice.formatted_invoice_number, size: 14, align: :center
    pdf.move_down 5
    pdf.text "Emitida em: #{I18n.l(@invoice.issued_at, format: :long)}", size: 10, align: :center
    
    if @invoice.cancelled?
      pdf.move_down 10
      pdf.text "*** CANCELADA ***", size: 14, style: :bold, align: :center, color: 'FF0000'
      pdf.text "Cancelada em: #{I18n.l(@invoice.cancelled_at, format: :long)}", size: 10, align: :center, color: 'FF0000'
    end
    
    pdf.move_down 20
  end
  
  def add_provider_data(pdf)
    pdf.text "DADOS DO PRESTADOR", size: 12, style: :bold
    pdf.move_down 10
    
    data = [
      ["Razão Social:", @company.company_name || "—"],
      ["CNPJ:", @company.formatted_cnpj || "—"],
      ["Endereço:", @company.address || "—"],
      ["Cidade/UF:", "#{@company.city} - #{@company.state}" || "—"],
      ["Telefone:", @company.phone || "—"],
      ["Email:", @company.email || "—"]
    ]
    
    pdf.table(data, width: pdf.bounds.width, cell_style: { borders: [] }) do
      column(0).font_style = :bold
      column(0).width = 120
    end
    
    pdf.move_down 20
  end
  
  def add_customer_data(pdf)
    pdf.text "DADOS DO TOMADOR (CLIENTE)", size: 12, style: :bold
    pdf.move_down 10
    
    data = [
      ["Nome/Razão Social:", @invoice.customer_name || @service_order.customer_name || "—"],
      ["CPF/CNPJ:", @invoice.customer_cpf_cnpj || "—"],
      ["Endereço:", @invoice.customer_address || "—"],
      ["Cidade/UF:", "#{@invoice.customer_city} - #{@invoice.customer_state}" || "—"],
      ["Telefone:", @service_order.customer_phone || "—"],
      ["Email:", @service_order.customer_email || "—"]
    ]
    
    pdf.table(data, width: pdf.bounds.width, cell_style: { borders: [] }) do
      column(0).font_style = :bold
      column(0).width = 120
    end
    
    pdf.move_down 20
  end
  
  def add_service_description(pdf)
    pdf.text "DESCRIÇÃO DO SERVIÇO", size: 12, style: :bold
    pdf.move_down 10
    
    pdf.text "Ordem de Serviço: ##{@service_order.id}", style: :bold
    pdf.text "Título: #{@service_order.title}"
    pdf.move_down 5
    pdf.text "Descrição:", style: :bold
    pdf.text @service_order.description
    
    if @service_order.equipment_name.present?
      pdf.move_down 5
      pdf.text "Equipamento: #{@service_order.equipment_info}"
    end
    
    pdf.move_down 20
  end
  
  def add_values_table(pdf)
    pdf.text "VALORES E IMPOSTOS", size: 12, style: :bold
    pdf.move_down 10
    
    table_data = [
      ["Descrição", "Valor"],
      ["Valor do Serviço", @invoice.formatted_total_value],
      ["(-) ISS (#{@invoice.iss_rate}%)", @invoice.formatted_iss_value],
      ["(-) PIS (0,65%)", format_currency(@invoice.pis_value)],
      ["(-) COFINS (3%)", format_currency(@invoice.cofins_value)],
      ["", ""],
      ["VALOR LÍQUIDO", @invoice.formatted_net_value]
    ]
    
    pdf.table(table_data, width: pdf.bounds.width) do
      row(0).font_style = :bold
      row(0).background_color = 'DDDDDD'
      row(-1).font_style = :bold
      row(-1).background_color = 'FFFFCC'
      column(1).align = :right
    end
    
    pdf.move_down 20
  end
  
  def add_notes(pdf)
    pdf.text "OBSERVAÇÕES", size: 12, style: :bold
    pdf.move_down 10
    pdf.text @invoice.notes
    pdf.move_down 20
  end
  
  def add_footer(pdf)
    pdf.move_down 30
    pdf.stroke_horizontal_rule
    pdf.move_down 10
    
    pdf.text "Este documento não possui validade fiscal.", size: 8, align: :center, color: '666666'
    pdf.text "Emitido eletronicamente pelo Sistema de Ordens de Serviço", size: 8, align: :center, color: '666666'
  end
  
  def format_currency(value)
    "R$ #{format('%.2f', value || 0)}"
  end
end
```

---

### **PASSO 6: Atualizar Routes**

Adicionar em `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  # ... rotas existentes ...
  
  # Invoices (Notas Fiscais)
  resources :invoices, only: [:index, :show, :edit, :update] do
    member do
      patch :cancel
      get :pdf
    end
  end
  
  # Gerar nota fiscal a partir de ordem de serviço
  resources :service_orders do
    resources :invoices, only: [:new, :create]
  end
  
  # ... resto das rotas ...
end
```

---

### **PASSO 7: Criar Views**

#### **app/views/invoices/index.html.erb:**

```erb
<div class="container mt-4">
  <div class="d-flex justify-content-between align-items-center mb-4">
    <h1><i class="bi bi-receipt"></i> Notas Fiscais</h1>
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
                ["Cancelada", "cancelled"],
                ["Rascunho", "draft"]
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
                  <td><%= l(invoice.issued_at, format: :short) %></td>
                  <td><strong><%= invoice.formatted_total_value %></strong></td>
                  <td>
                    <span class="badge <%= invoice.status_badge_class %>">
                      <%= t("activerecord.attributes.invoice.statuses.#{invoice.status}") %>
                    </span>
                  </td>
                  <td>
                    <%= link_to "Ver", invoice, class: "btn btn-sm btn-info" %>
                    <%= link_to "PDF", pdf_invoice_path(invoice), 
                        class: "btn btn-sm btn-danger", target: "_blank" %>
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

#### **app/views/invoices/show.html.erb:**

```erb
<div class="container mt-4">
  <div class="d-flex justify-content-between align-items-center mb-4">
    <h1><i class="bi bi-receipt"></i> Nota Fiscal <%= @invoice.formatted_invoice_number %></h1>
    
    <div>
      <%= link_to "Voltar", invoices_path, class: "btn btn-secondary" %>
      <%= link_to "PDF", pdf_invoice_path(@invoice), 
          class: "btn btn-danger", target: "_blank" %>
      
      <% if current_user.admin? && @invoice.can_be_cancelled? %>
        <%= button_to "Cancelar NF", cancel_invoice_path(@invoice), 
            method: :patch, 
            class: "btn btn-warning",
            data: { confirm: "Tem certeza que deseja cancelar esta nota fiscal?" } %>
      <% end %>
    </div>
  </div>
  
  <!-- Status -->
  <div class="alert alert-<%= @invoice.issued? ? 'success' : 'warning' %>">
    <strong>Status:</strong>
    <span class="badge <%= @invoice.status_badge_class %>">
      <%= t("activerecord.attributes.invoice.statuses.#{@invoice.status}") %>
    </span>
    
    <% if @invoice.cancelled? %>
      <br>
      <strong>Cancelada em:</strong> <%= l(@invoice.cancelled_at, format: :long) %>
    <% end %>
  </div>
  
  <!-- Dados da Nota -->
  <div class="row">
    <div class="col-md-6">
      <div class="card mb-4">
        <div class="card-header">
          <h5><i class="bi bi-info-circle"></i> Identificação</h5>
        </div>
        <div class="card-body">
          <p><strong>Número:</strong> <%= @invoice.invoice_number %></p>
          <p><strong>Série:</strong> <%= @invoice.serie %></p>
          <p><strong>Emissão:</strong> <%= l(@invoice.issued_at, format: :long) %></p>
          <p><strong>Ordem de Serviço:</strong> 
            <%= link_to "##{@invoice.service_order.id}", @invoice.service_order %>
          </p>
        </div>
      </div>
    </div>
    
    <div class="col-md-6">
      <div class="card mb-4">
        <div class="card-header">
          <h5><i class="bi bi-person"></i> Cliente</h5>
        </div>
        <div class="card-body">
          <p><strong>Nome:</strong> <%= @invoice.customer_name %></p>
          <p><strong>CPF/CNPJ:</strong> <%= @invoice.customer_cpf_cnpj || "—" %></p>
          <p><strong>Endereço:</strong> <%= @invoice.customer_address || "—" %></p>
          <p><strong>Cidade/UF:</strong> 
            <%= "#{@invoice.customer_city} - #{@invoice.customer_state}" if @invoice.customer_city.present? %>
          </p>
        </div>
      </div>
    </div>
  </div>
  
  <!-- Valores -->
  <div class="card mb-4">
    <div class="card-header">
      <h5><i class="bi bi-currency-dollar"></i> Valores e Impostos</h5>
    </div>
    <div class="card-body">
      <div class="table-responsive">
        <table class="table">
          <tr>
            <td><strong>Valor do Serviço:</strong></td>
            <td class="text-end"><%= @invoice.formatted_total_value %></td>
          </tr>
          <tr>
            <td>(-) ISS (<%= @invoice.iss_rate %>%):</td>
            <td class="text-end text-danger"><%= @invoice.formatted_iss_value %></td>
          </tr>
          <tr>
            <td>(-) PIS (0,65%):</td>
            <td class="text-end text-danger">
              R$ <%= format('%.2f', @invoice.pis_value) %>
            </td>
          </tr>
          <tr>
            <td>(-) COFINS (3%):</td>
            <td class="text-end text-danger">
              R$ <%= format('%.2f', @invoice.cofins_value) %>
            </td>
          </tr>
          <tr class="table-success">
            <td><strong>VALOR LÍQUIDO:</strong></td>
            <td class="text-end"><strong><%= @invoice.formatted_net_value %></strong></td>
          </tr>
        </table>
      </div>
    </div>
  </div>
  
  <!-- Observações -->
  <% if @invoice.notes.present? %>
    <div class="card mb-4">
      <div class="card-header">
        <h5><i class="bi bi-chat-text"></i> Observações</h5>
      </div>
      <div class="card-body">
        <%= simple_format @invoice.notes %>
      </div>
    </div>
  <% end %>
</div>
```

#### **app/views/invoices/new.html.erb:**

```erb
<div class="container mt-4">
  <h1><i class="bi bi-receipt"></i> Emitir Nota Fiscal</h1>
  <p class="text-muted">Ordem de Serviço #<%= @service_order.id %> - <%= @service_order.title %></p>
  
  <div class="row mt-4">
    <div class="col-md-8">
      <%= form_with model: [@service_order, @invoice], local: true do |f| %>
        <%= render 'shared/error_messages', object: @invoice %>
        
        <div class="card mb-3">
          <div class="card-header">
            <h5>Identificação</h5>
          </div>
          <div class="card-body">
            <div class="mb-3">
              <%= f.label :serie, "Série", class: "form-label" %>
              <%= f.text_field :serie, class: "form-control", value: "001" %>
              <small class="text-muted">Série da nota fiscal (ex: 001)</small>
            </div>
            
            <div class="mb-3">
              <%= f.label :iss_rate, "Alíquota ISS (%)", class: "form-label" %>
              <%= f.number_field :iss_rate, 
                  class: "form-control", 
                  step: 0.01, 
                  min: 0, 
                  max: 100,
                  value: 5.00 %>
              <small class="text-muted">Varia de 2% a 5% conforme município</small>
            </div>
          </div>
        </div>
        
        <div class="card mb-3">
          <div class="card-header">
            <h5>Dados do Cliente (Tomador)</h5>
          </div>
          <div class="card-body">
            <div class="mb-3">
              <%= f.label :customer_name, "Nome/Razão Social", class: "form-label" %>
              <%= f.text_field :customer_name, 
                  class: "form-control",
                  value: @service_order.customer_name %>
            </div>
            
            <div class="mb-3">
              <%= f.label :customer_cpf_cnpj, "CPF/CNPJ", class: "form-label" %>
              <%= f.text_field :customer_cpf_cnpj, class: "form-control" %>
            </div>
            
            <div class="mb-3">
              <%= f.label :customer_address, "Endereço", class: "form-label" %>
              <%= f.text_field :customer_address, class: "form-control" %>
            </div>
            
            <div class="row">
              <div class="col-md-6 mb-3">
                <%= f.label :customer_city, "Cidade", class: "form-label" %>
                <%= f.text_field :customer_city, class: "form-control" %>
              </div>
              
              <div class="col-md-6 mb-3">
                <%= f.label :customer_state, "Estado", class: "form-label" %>
                <%= f.select :customer_state,
                    options_for_select([
                      ["AC"], ["AL"], ["AP"], ["AM"], ["BA"],
                      ["CE"], ["DF"], ["ES"], ["GO"], ["MA"],
                      ["MT"], ["MS"], ["MG"], ["PA"], ["PB"],
                      ["PR"], ["PE"], ["PI"], ["RJ"], ["RN"],
                      ["RS"], ["RO"], ["RR"], ["SC"], ["SP"],
                      ["SE"], ["TO"]
                    ]),
                    { include_blank: "Selecione" },
                    class: "form-select" %>
              </div>
            </div>
            
            <div class="mb-3">
              <%= f.label :customer_zip_code, "CEP", class: "form-label" %>
              <%= f.text_field :customer_zip_code, class: "form-control" %>
            </div>
          </div>
        </div>
        
        <div class="card mb-3">
          <div class="card-header">
            <h5>Observações</h5>
          </div>
          <div class="card-body">
            <%= f.text_area :notes, 
                class: "form-control", 
                rows: 4,
                placeholder: "Observações adicionais (opcional)" %>
          </div>
        </div>
        
        <div class="d-flex gap-2">
          <%= f.submit "Emitir Nota Fiscal", class: "btn btn-success" %>
          <%= link_to "Cancelar", @service_order, class: "btn btn-secondary" %>
        </div>
      <% end %>
    </div>
    
    <div class="col-md-4">
      <div class="card">
        <div class="card-header">
          <h5>Resumo</h5>
        </div>
        <div class="card-body">
          <p><strong>Valor do Serviço:</strong><br>
            <%= @service_order.formatted_total_value %></p>
          
          <p><strong>Impostos Estimados:</strong></p>
          <ul class="small">
            <li>ISS (5%): R$ <%= format('%.2f', @service_order.total_value * 0.05) %></li>
            <li>PIS (0,65%): R$ <%= format('%.2f', @service_order.total_value * 0.0065) %></li>
            <li>COFINS (3%): R$ <%= format('%.2f', @service_order.total_value * 0.03) %></li>
          </ul>
          
          <hr>
          
          <p class="text-success"><strong>Valor Líquido Estimado:</strong><br>
            R$ <%= format('%.2f', @service_order.total_value * 0.9135) %>
          </p>
          
          <div class="alert alert-info small">
            <i class="bi bi-info-circle"></i>
            Esta nota fiscal NÃO tem validade fiscal. É apenas para controle interno.
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
```

---

### **PASSO 8: Adicionar Tradução**

Adicionar em `config/locales/pt-BR.yml`:

```yaml
pt-BR:
  activerecord:
    models:
      invoice:
        one: "Nota Fiscal"
        other: "Notas Fiscais"
    attributes:
      invoice:
        invoice_number: "Número"
        serie: "Série"
        issued_at: "Data de Emissão"
        cancelled_at: "Data de Cancelamento"
        status: "Status"
        service_value: "Valor do Serviço"
        total_value: "Valor Total"
        iss_rate: "Alíquota ISS"
        iss_value: "Valor ISS"
        net_value: "Valor Líquido"
        customer_name: "Nome do Cliente"
        customer_cpf_cnpj: "CPF/CNPJ"
        notes: "Observações"
        statuses:
          draft: "Rascunho"
          issued: "Emitida"
          cancelled: "Cancelada"
```

---

### **PASSO 9: Adicionar Link no Service Order Show**

Adicionar em `app/views/service_orders/show.html.erb`:

```erb
<!-- Adicionar no card de ações laterais -->
<% if current_user.admin? && @service_order.can_generate_invoice? %>
  <%= link_to new_service_order_invoice_path(@service_order), 
      class: "btn btn-success w-100 mb-2" do %>
    <i class="bi bi-receipt"></i> Emitir Nota Fiscal
  <% end %>
<% end %>

<% if @service_order.has_invoice? %>
  <%= link_to invoice_path(@service_order.invoice), 
      class: "btn btn-info w-100 mb-2" do %>
    <i class="bi bi-receipt-cutoff"></i> Ver Nota Fiscal
  <% end %>
<% end %>
```

---

### **PASSO 10: Testar Tudo**

```bash
# 1. Executar migration
cd /home/user/webapp
rails db:migrate

# 2. Iniciar servidor
rails server

# 3. Acessar sistema
# http://localhost:3000

# 4. Criar/Completar uma ordem de serviço

# 5. Emitir nota fiscal

# 6. Visualizar PDF
```

---

## 🌐 IMPLEMENTAÇÃO AVANÇADA (API Prefeitura)

### Opções de Integração

#### **1. NFE.io** (Recomendado) ⭐
- **Site:** https://nfe.io
- **Custo:** R$ 20-200/mês (conforme volume)
- **Cidades:** 5.000+ municípios
- **Gem:** `nfe-ruby`

**Vantagens:**
- ✅ API unificada para todas as cidades
- ✅ Documentação excelente
- ✅ Suporte técnico
- ✅ Homologação fácil

**Implementação:**
```ruby
# Gemfile
gem 'nfe-ruby'

# config/initializers/nfe_io.rb
NFe.api_key = ENV['NFE_IO_API_KEY']
NFe.company_id = ENV['NFE_IO_COMPANY_ID']

# app/services/nfe_issuer.rb
class NfeIssuer
  def self.issue(invoice)
    nfe = NFe::ServiceInvoice.create(
      borrower: {
        name: invoice.customer_name,
        email: invoice.service_order.customer_email,
        # ... mais dados
      },
      services: [{
        description: invoice.service_order.description,
        amount: invoice.total_value
      }]
    )
    
    # Salvar número oficial da prefeitura
    invoice.update(
      official_number: nfe.number,
      verification_code: nfe.verification_code
    )
  end
end
```

#### **2. API Direta da Prefeitura**
- Cada prefeitura tem sua API própria
- Mais complexo de implementar
- Sem custo mensal (na maioria)
- Requer certificado digital

**Prefeituras com APIs públicas:**
- São Paulo: https://nfe.prefeitura.sp.gov.br
- Rio de Janeiro: https://notacarioca.rio.gov.br
- Belo Horizonte: https://bhissdigital.pbh.gov.br

---

## 📚 PRÓXIMOS PASSOS

### **Curto Prazo:**
1. ✅ Implementar versão básica (PDF) - 2-3 horas
2. ✅ Testar com dados reais
3. ✅ Ajustar layout do PDF conforme necessidade
4. ✅ Adicionar mais campos se necessário (desconto, retenções)

### **Médio Prazo:**
1. 📊 Adicionar relatório de notas fiscais emitidas
2. 💰 Integrar com gestão financeira (receitas)
3. 📧 Enviar PDF por email automaticamente
4. 🔢 Adicionar numeração por ano

### **Longo Prazo:**
1. 🌐 Integração com NFE.io ou API prefeitura
2. 📱 Geração de QR Code
3. 🔐 Assinatura digital
4. 🏛️ Envio automático para prefeitura

---

## 🆘 SUPORTE E DÚVIDAS

### Documentação Adicional:
- **Prawn PDF:** https://prawnpdf.org/docs/
- **NFE.io:** https://nfe.io/docs
- **ISS por Município:** Consultar site da prefeitura local

### Dúvidas Comuns:

**Q: Esta nota tem validade fiscal?**  
A: Não. A versão básica é apenas para controle interno.

**Q: Preciso de certificado digital?**  
A: Não para versão básica. Sim para integração oficial.

**Q: Como integrar com a prefeitura?**  
A: Use NFE.io (mais fácil) ou API direta da prefeitura (mais complexo).

**Q: Qual a alíquota de ISS?**  
A: Varia de 2% a 5% conforme município e tipo de serviço.

---

## ✅ CHECKLIST DE IMPLEMENTAÇÃO

- [ ] Migration criada e executada
- [ ] Model Invoice criado
- [ ] ServiceOrder atualizado com associação
- [ ] InvoicesController criado
- [ ] InvoicePdfGenerator criado
- [ ] Routes adicionadas
- [ ] Views criadas (index, show, new)
- [ ] Traduções adicionadas
- [ ] Links adicionados em ServiceOrder
- [ ] Testado end-to-end
- [ ] PDF gerado com sucesso
- [ ] Impostos calculados corretamente

---

**Pronto! Com este guia você pode implementar um sistema completo de nota fiscal de serviço!** 🎉

Para começar, execute os comandos do **PASSO 1** e siga em ordem até o **PASSO 10**.

**Tempo estimado:** 2-3 horas para implementação completa da versão básica.
