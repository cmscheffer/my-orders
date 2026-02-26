# ⚡ QUICKSTART - NFE.io em 1 Hora

## 🎯 IMPLEMENTAÇÃO RÁPIDA

Siga estes passos em ordem para ter NFS-e funcionando em **1 hora**.

---

## ✅ CHECKLIST RÁPIDO

### **PREPARAÇÃO (10 min)**
- [ ] Criar conta no NFE.io (https://nfe.io)
- [ ] Copiar API Key e Company ID
- [ ] Configurar dados da empresa
- [ ] Upload certificado digital (se tiver)

### **CÓDIGO (40 min)**
- [ ] Adicionar gems ao Gemfile
- [ ] Criar migration
- [ ] Criar model Invoice
- [ ] Criar service NfeioService
- [ ] Criar controller
- [ ] Criar views
- [ ] Configurar routes

### **TESTE (10 min)**
- [ ] Executar migration
- [ ] Testar criação de invoice
- [ ] Testar emissão
- [ ] Verificar PDF

---

## 🚀 PASSO A PASSO RÁPIDO

### **1. NFE.io (5 min)**

```bash
# 1. Criar conta: https://nfe.io
# 2. Dashboard → Configurações → Integrações
# 3. Copiar:
#    - API Key: abc123...
#    - Company ID: comp_123...
```

---

### **2. Gemfile (1 min)**

```ruby
# Adicionar no Gemfile:
gem 'httparty', '~> 0.21'
gem 'dotenv-rails', '~> 2.8'
```

```bash
bundle install
```

---

### **3. Environment (2 min)**

```bash
# Criar .env na raiz:
cat > .env << 'EOF'
NFEIO_API_KEY=sua_api_key_aqui
NFEIO_COMPANY_ID=seu_company_id_aqui
NFEIO_ENVIRONMENT=development
NFEIO_WEBHOOK_SECRET=test_secret_123
EOF

# Adicionar ao .gitignore:
echo ".env" >> .gitignore
```

---

### **4. Migration (2 min)**

```bash
rails generate migration CreateInvoices
```

Copie este código para a migration:

```ruby
class CreateInvoices < ActiveRecord::Migration[7.1]
  def change
    create_table :invoices do |t|
      t.references :service_order, null: false, foreign_key: true
      t.string :invoice_number, null: false
      t.string :serie, default: "001"
      t.datetime :issued_at
      t.integer :status, default: 0
      t.decimal :total_value, precision: 10, scale: 2
      t.decimal :iss_rate, precision: 5, scale: 2, default: 5.00
      t.string :customer_name
      t.string :customer_cpf_cnpj
      t.string :customer_email
      t.string :nfeio_id
      t.string :official_number
      t.string :pdf_url
      t.text :error_message
      t.timestamps
    end
    
    add_index :invoices, :invoice_number, unique: true
    add_index :invoices, :nfeio_id, unique: true
  end
end
```

```bash
rails db:migrate
```

---

### **5. Arquivos (30 min)**

**TODOS os arquivos completos estão em:**
- `IMPLEMENTACAO_NFEIO.md` (Parte 1)
- `IMPLEMENTACAO_NFEIO_PARTE2.md` (Parte 2)

**Copie nesta ordem:**

1. `config/initializers/nfeio.rb`
2. `app/models/invoice.rb`
3. `app/services/nfeio_service.rb`
4. `app/controllers/invoices_controller.rb`
5. `config/routes.rb` (adicionar rotas)
6. `app/views/invoices/index.html.erb`
7. `app/views/invoices/show.html.erb`
8. `app/views/invoices/new.html.erb`

**Todos os códigos completos estão nos guias!**

---

### **6. Testar (10 min)**

```bash
# 1. Iniciar servidor
rails server

# 2. Acessar
http://localhost:3000

# 3. Criar ordem de serviço completa (se não tiver)

# 4. Emitir nota fiscal
# - Ir na ordem de serviço
# - Clicar em "Emitir NFS-e"
# - Preencher dados do cliente
# - Criar rascunho
# - Clicar em "Emitir no NFE.io"

# 5. Verificar resultado
# - Ver número oficial
# - Baixar PDF
```

---

## 📋 COMANDOS COMPLETOS

```bash
# Setup completo em sequência:

cd /home/user/webapp

# 1. Gems
echo "gem 'httparty', '~> 0.21'" >> Gemfile
echo "gem 'dotenv-rails', '~> 2.8'" >> Gemfile
bundle install

# 2. Environment
cat > .env << 'EOF'
NFEIO_API_KEY=sua_api_key
NFEIO_COMPANY_ID=seu_company_id
NFEIO_ENVIRONMENT=development
NFEIO_WEBHOOK_SECRET=test_secret
EOF

echo ".env" >> .gitignore

# 3. Migration
rails generate migration CreateInvoices
# (editar migration com código do guia)
rails db:migrate

# 4. Copiar arquivos dos guias
# (ver IMPLEMENTACAO_NFEIO.md e PARTE2.md)

# 5. Reiniciar
rails server

# 6. Testar!
```

---

## 🔧 TROUBLESHOOTING RÁPIDO

### **Erro: "API Key não configurada"**
```bash
# Verificar .env:
cat .env

# Reiniciar servidor:
rails server
```

### **Erro: "Couldn't find Company"**
```bash
# Company ID errado no .env
# Verificar no dashboard NFE.io
```

### **Erro ao emitir**
```bash
# Ver logs:
tail -f log/development.log

# Verificar resposta NFE.io no show da invoice
```

---

## 📊 FLUXO DE USO

```
1. Ordem de Serviço Concluída
         ↓
2. Clicar "Emitir NFS-e"
         ↓
3. Preencher Dados Cliente
         ↓
4. Criar Rascunho (status: draft)
         ↓
5. Clicar "Emitir no NFE.io"
         ↓
6. Aguardar (status: processing)
         ↓
7. Nota Emitida! (status: issued)
         ↓
8. Baixar PDF Oficial
```

---

## 💰 CUSTOS

| Volume | Plano | Preço/mês |
|--------|-------|-----------|
| Até 100 | Starter | R$ 20 |
| Até 500 | Básico | R$ 50 |
| Até 2.000 | Pro | R$ 120 |
| 10.000+ | Enterprise | R$ 300+ |

**Teste grátis:** 7 dias (até 10 notas)

---

## 📚 DOCUMENTAÇÃO COMPLETA

### **Leia para entender tudo:**

1. **IMPLEMENTACAO_NFEIO.md** (22KB)
   - Setup detalhado
   - Model completo
   - Service completo
   - Controller completo

2. **IMPLEMENTACAO_NFEIO_PARTE2.md** (25KB)
   - Views completas
   - Webhooks
   - Deploy
   - Troubleshooting

3. **Este arquivo** (QUICKSTART)
   - Implementação rápida
   - Comandos diretos

---

## ✅ RESULTADO FINAL

Após implementar, você terá:

✅ **NFS-e com validade fiscal oficial**  
✅ **Integração automática com NFE.io**  
✅ **PDF da prefeitura**  
✅ **Webhooks para atualizações**  
✅ **Interface completa**  
✅ **Gestão de erros**  
✅ **Cancelamento de notas**

---

## 🎯 PRÓXIMOS PASSOS

### **Após implementar:**

1. **Testar em development:**
   - Emitir 2-3 notas de teste
   - Verificar PDF
   - Testar cancelamento

2. **Configurar produção:**
   - Comprar certificado digital
   - Configurar empresa no NFE.io
   - Configurar webhook
   - Deploy

3. **Treinar usuários:**
   - Como emitir nota
   - Como cancelar
   - Como baixar PDF

4. **Monitorar:**
   - Primeiras emissões reais
   - Erros (se houver)
   - Feedback de clientes

---

## 🆘 AJUDA

**Tem dúvida?**
- Leia os guias completos (IMPLEMENTACAO_NFEIO.md)
- Veja exemplos de código
- Verifique logs: `tail -f log/development.log`
- Suporte NFE.io: suporte@nfe.io

**Links:**
- Dashboard: https://app.nfe.io
- Docs: https://docs.nfe.io
- Status: https://status.nfe.io

---

## 🎉 BOA SORTE!

**Você tem 1 hora para implementar.**

**Começe agora!** ⚡

---

**Documentação completa em:**
- `IMPLEMENTACAO_NFEIO.md`
- `IMPLEMENTACAO_NFEIO_PARTE2.md`

**Desenvolvido para o Sistema de Ordens de Serviço**  
**Ruby on Rails 7.1 + NFE.io 💎**
