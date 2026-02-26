# ⚡ QUICKSTART - Nota Fiscal em 30 Minutos

## 🎯 O QUE VOCÊ VAI TER

✅ Nota Fiscal de Serviço em PDF profissional  
✅ Cálculo automático de impostos (ISS, PIS, COFINS)  
✅ Numeração sequencial automática  
✅ Gestão completa (emitir, visualizar, cancelar)  
❌ **NÃO tem validade fiscal** (apenas controle interno)

---

## 🚀 IMPLEMENTAÇÃO RÁPIDA

### **PASSO 1: Criar Migration (2 min)**

```bash
cd /home/user/webapp
rails generate migration CreateInvoices
```

Cole isto no arquivo gerado em `db/migrate/`:

```ruby
class CreateInvoices < ActiveRecord::Migration[7.1]
  def change
    create_table :invoices do |t|
      t.references :service_order, null: false, foreign_key: true
      t.string :invoice_number, null: false
      t.string :serie, default: "001"
      t.datetime :issued_at, null: false
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
      
      t.timestamps
    end
    
    add_index :invoices, :invoice_number, unique: true
    add_index :invoices, :status
  end
end
```

Execute:
```bash
rails db:migrate
```

---

### **PASSO 2: Baixar Arquivos Prontos**

Eu vou criar os 4 arquivos principais para você agora:

1. ✅ `app/models/invoice.rb`
2. ✅ `app/controllers/invoices_controller.rb`
3. ✅ `app/services/invoice_pdf_generator.rb`
4. ✅ Routes em `config/routes.rb`

---

### **PASSO 3: Usar no Sistema (2 min)**

1. Complete uma ordem de serviço
2. Clique em "Emitir Nota Fiscal"
3. Preencha dados do cliente
4. Clique em "Emitir"
5. Baixe o PDF!

---

## 📊 COMO FUNCIONA

```
Ordem de Serviço Concluída
         ↓
   [Emitir Nota Fiscal]
         ↓
    Cálculo Automático:
    - Total: R$ 1.000,00
    - ISS 5%: R$ 50,00
    - PIS 0,65%: R$ 6,50
    - COFINS 3%: R$ 30,00
    = Líquido: R$ 913,50
         ↓
    Gera PDF Profissional
```

---

## 💰 CÁLCULO DE IMPOSTOS

| Imposto | Alíquota | Sobre | Exemplo (R$ 1.000) |
|---------|----------|-------|---------------------|
| **ISS** | 2-5% | Total | R$ 50,00 (5%) |
| **PIS** | 0,65% | Total | R$ 6,50 |
| **COFINS** | 3% | Total | R$ 30,00 |
| **Líquido** | — | Total - Impostos | R$ 913,50 |

---

## 🔍 RECURSOS

### **Gestão:**
- ✅ Listagem de todas as notas
- ✅ Filtro por status
- ✅ Visualização detalhada
- ✅ Cancelamento (admin)
- ✅ Geração de PDF

### **PDF Profissional:**
- ✅ Logo da empresa
- ✅ Dados completos (prestador e tomador)
- ✅ Descrição do serviço
- ✅ Tabela de valores e impostos
- ✅ Layout limpo e imprimível

### **Automações:**
- ✅ Numeração sequencial automática
- ✅ Cálculo de impostos automático
- ✅ Data de emissão automática
- ✅ Validações completas

---

## ⚠️ LIMITAÇÕES DA VERSÃO BÁSICA

| Item | Versão Básica | Versão Oficial |
|------|---------------|----------------|
| Validade Fiscal | ❌ Não | ✅ Sim |
| Prefeitura | ❌ Não envia | ✅ Envia |
| Custo | ✅ Grátis | 💰 R$ 20-200/mês |
| Implementação | ⚡ 30 min | ⏰ 1-2 semanas |
| Certificado Digital | ❌ Não precisa | ✅ Precisa |

---

## 🎓 PARA EMISSÃO OFICIAL

Se você precisar emitir notas **com validade fiscal**, você tem 2 opções:

### **Opção 1: NFE.io** (Mais Fácil) ⭐
- Site: https://nfe.io
- Custo: R$ 20-200/mês
- Funciona em 5.000+ cidades
- API unificada
- Tempo: 2-3 dias

### **Opção 2: API Prefeitura** (Mais Complexo)
- Cada cidade tem sua API
- Grátis (na maioria)
- Requer certificado digital
- Tempo: 1-2 semanas

---

## 📁 ESTRUTURA CRIADA

```
app/
├── models/
│   └── invoice.rb                    # Model da nota fiscal
├── controllers/
│   └── invoices_controller.rb        # CRUD de notas
├── services/
│   └── invoice_pdf_generator.rb      # Gerador de PDF
└── views/
    └── invoices/
        ├── index.html.erb            # Listagem
        ├── show.html.erb             # Detalhes
        └── new.html.erb              # Formulário

db/
└── migrate/
    └── xxx_create_invoices.rb        # Migration
```

---

## ✅ CHECKLIST

- [ ] Migration criada e executada
- [ ] Arquivos Ruby criados (próximo passo)
- [ ] Routes adicionadas
- [ ] Servidor reiniciado
- [ ] Testado com ordem de serviço
- [ ] PDF gerado com sucesso

---

## 🆘 PRÓXIMOS PASSOS

Agora vou criar os arquivos Ruby para você!

**Tempo restante:** 20 minutos

Continue na próxima mensagem...
