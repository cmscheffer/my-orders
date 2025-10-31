# 🧪 GUIA DE TESTES AUTOMATIZADOS

## 📋 Configuração Inicial

### 1. Instalar as gems de teste

No seu **WSL2**, execute:

```bash
cd /home/user/webapp/service_orders_app
bundle install
```

### 2. Instalar RSpec

```bash
rails generate rspec:install
```

**Nota:** Se o comando acima sobrescrever arquivos, escolha **não sobrescrever** os arquivos `spec/spec_helper.rb` e `spec/rails_helper.rb` pois já foram configurados com todas as funcionalidades.

### 3. Preparar o banco de dados de teste

```bash
rails db:test:prepare
```

## 🚀 Executando os Testes

### Executar TODOS os testes:

```bash
bundle exec rspec
```

### Executar testes de um arquivo específico:

```bash
# Testes do model User
bundle exec rspec spec/models/user_spec.rb

# Testes do model ServiceOrder
bundle exec rspec spec/models/service_order_spec.rb

# Testes do controller Users
bundle exec rspec spec/controllers/users_controller_spec.rb

# Testes do controller ServiceOrders
bundle exec rspec spec/controllers/service_orders_controller_spec.rb
```

### Executar um teste específico (por linha):

```bash
bundle exec rspec spec/models/user_spec.rb:10
```

### Executar testes com formatação detalhada:

```bash
bundle exec rspec --format documentation
```

### Ver cobertura de código:

Após executar os testes, abra:

```bash
open coverage/index.html  # No Mac
xdg-open coverage/index.html  # No Linux/WSL
```

## 📊 O que foi testado

### ✅ **User Model** (spec/models/user_spec.rb)
- ✅ Associações (service_orders, technician)
- ✅ Validações (name, email, uniqueness)
- ✅ Enums (user, admin) - **Esse teste teria pego o bug do role!**
- ✅ Callbacks (default role)
- ✅ Devise modules
- ✅ Factory validation
- ✅ Instance methods (admin?, user?)
- ✅ Edge cases (empty name, duplicate email, short password)

### ✅ **ServiceOrder Model** (spec/models/service_order_spec.rb)
- ✅ Associações (user, technician, parts)
- ✅ Validações (title, description, numericality)
- ✅ Enums (status, priority, payment_status)
- ✅ Callbacks (calculate_total_value)
- ✅ Scopes (recent, by_status, by_priority)
- ✅ Métodos de negócio (can_be_completed?, mark_as_completed!)
- ✅ Métodos de apresentação (badge_class, formatted_values)
- ✅ Edge cases (nil values, overdue logic)

### ✅ **UsersController** (spec/controllers/users_controller_spec.rb)
- ✅ Autorização admin vs usuário regular
- ✅ CRUD completo (create, read, update, delete)
- ✅ Validação de role correto
- ✅ Proteção contra roles inválidos (technician)
- ✅ Update sem alterar senha
- ✅ Admin não pode se deletar

### ✅ **ServiceOrdersController** (spec/controllers/service_orders_controller_spec.rb)
- ✅ Autorização (admin vê tudo, user vê só suas ordens)
- ✅ CRUD completo
- ✅ Filtros (status, priority)
- ✅ Actions especiais (complete, cancel)
- ✅ Geração de PDF
- ✅ Proteção de edição/exclusão

## 🏭 Factories (FactoryBot)

As factories permitem criar dados de teste facilmente:

```ruby
# Criar um usuário regular
user = create(:user)

# Criar um admin
admin = create(:user, :admin)

# Criar um usuário com 5 ordens de serviço
user_with_orders = create(:user, :with_service_orders, service_orders_count: 5)

# Criar uma ordem de serviço
order = create(:service_order)

# Criar uma ordem urgente e atrasada
urgent_order = create(:service_order, :urgent, :overdue)

# Criar uma ordem concluída
completed_order = create(:service_order, :completed)
```

## 📈 Resultado Esperado

Ao executar `bundle exec rspec`, você deve ver algo como:

```
User
  associations
    should have many service_orders dependent => destroy
    should have one technician dependent => destroy
  validations
    should validate that :name cannot be empty/falsy
    ...

ServiceOrder
  associations
    should belong to user
    ...

Finished in 5.23 seconds (files took 2.34 seconds to load)
85 examples, 0 failures
```

## 🎯 Cobertura de Código

O SimpleCov gera relatórios de cobertura automaticamente em `coverage/index.html`.

**Meta de cobertura:** 80%+ é considerado bom, 90%+ é excelente.

## 🔧 Troubleshooting

### Erro: "Factory not registered"
```bash
# Certifique-se de que as factories estão em spec/factories/
ls -la spec/factories/
```

### Erro: "Database is not prepared"
```bash
rails db:test:prepare
```

### Erro: "Devise test helpers not found"
```bash
# Verifique se o rails_helper.rb tem:
config.include Devise::Test::ControllerHelpers, type: :controller
```

### Testes muito lentos
```bash
# Use spring para acelerar:
bundle exec spring rspec
```

## 📝 Próximos Passos

1. **Adicionar mais testes:**
   - Testes de integração (request specs)
   - Testes de system (feature specs com Capybara)
   - Testes de services (ServiceOrderPdfGenerator)

2. **CI/CD:**
   - Configurar GitHub Actions para rodar testes automaticamente
   - Adicionar badge de build no README

3. **Manter testes atualizados:**
   - Sempre criar testes para novas features
   - Atualizar testes quando alterar código existente

## 🎓 Recursos

- [RSpec Documentation](https://rspec.info/)
- [FactoryBot Documentation](https://github.com/thoughtbot/factory_bot)
- [Shoulda Matchers](https://github.com/thoughtbot/shoulda-matchers)
- [Better Specs](https://www.betterspecs.org/)

---

**Criado em:** 2025-01-31  
**Última atualização:** 2025-01-31
