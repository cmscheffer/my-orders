# Changelog - Sistema de Ordens de Serviço

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

---

## [1.2.0] - 2024-01-15

### ✨ Adicionado
- **Campos Financeiros Completos**
  - `service_value`: Valor do serviço/mão de obra (decimal 10,2)
  - `parts_value`: Valor de peças/componentes (decimal 10,2)
  - `total_value`: Valor total calculado automaticamente (service_value + parts_value)
  - `payment_status`: Status do pagamento (enum: pending_payment, paid, partially_paid, cancelled_payment)
  - `payment_method`: Forma de pagamento (Dinheiro, Cartão, PIX, Boleto, etc.)
  - `payment_date`: Data do pagamento
  - `notes`: Observações financeiras/adicionais

### 🔄 Modificado
- **Model ServiceOrder**
  - Validações numéricas para valores (maior ou igual a 0)
  - Enum `payment_status` com 4 estados
  - Callback `before_save :calculate_total_value` para cálculo automático
  - Métodos formatados: `formatted_service_value()`, `formatted_parts_value()`, `formatted_total_value()`
  - Método `payment_status_badge_class()` para badges coloridos
  
- **Controller ServiceOrdersController**
  - Adicionados 7 novos parâmetros permitidos
  
- **Views**
  - Formulário `_form.html.erb`: Nova seção "Informações Financeiras" completa
    - Campos de valor do serviço e peças
    - Select de status do pagamento
    - Select de forma de pagamento (7 opções)
    - Campo de data de pagamento
    - Campo de observações
    - Alerta informativo sobre cálculo automático
  - View `show.html.erb`: Card dedicado "Informações Financeiras"
    - Exibe valores formatados em R$
    - Mostra valor total em destaque
    - Badge de status do pagamento
    - Observações quando preenchidas
  - View `index.html.erb`: Nova coluna "Valor Total"
    - Mostra valor em R$ formatado
    - Badge do status de pagamento (quando aplicável)
  
- **Database**
  - Migration `20240101000004_add_financial_fields_to_service_orders.rb`
    - Adiciona 7 novas colunas à tabela `service_orders`
    - Índices nos campos `payment_status` e `total_value`
  
- **Seeds**
  - Todos os 7 exemplos agora incluem valores financeiros realistas
  - Valores entre R$ 120,00 e R$ 1.850,00
  - Diferentes status de pagamento
  - Formas de pagamento variadas
  
- **Tradução (pt-BR)**
  - Adicionadas traduções para os 7 novos campos

### 💰 Funcionalidades Financeiras
- Cálculo automático do valor total
- Formatação monetária em Real (R$)
- Rastreamento completo de pagamentos
- Status de pagamento visual (badges coloridos)
- Suporte a pagamento parcial
- Campo de observações para detalhes adicionais

---

## [1.1.0] - 2024-01-15

### ✨ Adicionado
- **Campo de Equipamento nas Ordens de Serviço**
  - `equipment_name`: Nome/Tipo do equipamento (ex: Notebook, Impressora)
  - `equipment_brand`: Marca do equipamento (ex: HP, Dell, Lenovo)
  - `equipment_model`: Modelo do equipamento (ex: LaserJet Pro M404dn)
  - `equipment_serial`: Número de série do equipamento

### 🔄 Modificado
- **Model ServiceOrder**
  - Adicionada validação para `equipment_name` (máximo 100 caracteres, opcional)
  - Adicionado método `equipment_info()` para formatar informações do equipamento
  
- **Controller ServiceOrdersController**
  - Adicionados novos parâmetros permitidos: `equipment_name`, `equipment_brand`, `equipment_model`, `equipment_serial`
  
- **Views**
  - Formulário `_form.html.erb`: Nova seção "Informações do Equipamento" com 4 campos
  - View `show.html.erb`: Card separado mostrando detalhes completos do equipamento
  - View `index.html.erb`: Nova coluna "Equipamento" na tabela de listagem
  
- **Database**
  - Migration `20240101000003_add_equipment_to_service_orders.rb`
    - Adiciona 4 novas colunas à tabela `service_orders`
    - Cria índice no campo `equipment_serial` para buscas rápidas
  
- **Seeds**
  - Todos os 7 exemplos de ordens de serviço agora incluem dados de equipamento realistas
  
- **Tradução (pt-BR)**
  - Adicionadas traduções para os 4 novos campos

### 📊 Dados de Exemplo Atualizados
- Servidor Dell PowerEdge R740
- Desktop Lenovo ThinkCentre M720
- Impressora HP LaserJet Pro M404dn
- Roteador Cisco RV340
- Servidor HP ProLiant ML350 Gen10
- Notebook Dell Latitude 5420
- Desktop Positivo Master D640

---

## [1.0.0] - 2024-01-01

### ✨ Release Inicial
- Sistema completo de gerenciamento de ordens de serviço
- Autenticação de usuários com Devise
- Sistema de roles (User/Admin)
- CRUD completo de ordens de serviço
- Dashboard com estatísticas
- Interface responsiva com Bootstrap 5
- Filtros por status e prioridade
- Alertas de ordens atrasadas
- Internacionalização em português (pt-BR)
- Documentação completa (42.000+ linhas)

### 📦 Funcionalidades
- **Autenticação**: Login, Logout, Registro, Recuperação de senha
- **Ordens de Serviço**: Criar, Editar, Visualizar, Excluir, Concluir, Cancelar
- **Dashboard**: Estatísticas, Ordens recentes, Alertas
- **Clientes**: Nome, Email, Telefone
- **Status**: Pendente, Em Andamento, Concluída, Cancelada
- **Prioridade**: Baixa, Média, Alta, Urgente
- **Data de Vencimento**: Com alertas de atraso

### 📚 Documentação
- README.md - Documentação completa (10.600 linhas)
- COMO_USAR.md - Guia para iniciantes
- QUICKSTART.md - Instalação rápida (5 minutos)
- DEPLOY.md - Guia de deployment completo
- PROJECT_SUMMARY.md - Resumo técnico
- API_EXAMPLES.md - Guia para implementar API
- INDICE_DOCUMENTACAO.md - Índice de toda documentação
- INSTALL.sh - Script de instalação automática

---

## Próximas Versões Planejadas

### [1.2.0] - Futuro
- [ ] Sistema de comentários nas ordens
- [ ] Upload de anexos/fotos
- [ ] Notificações por email
- [ ] Histórico de alterações

### [1.3.0] - Futuro
- [ ] Relatórios em PDF
- [ ] Exportação para Excel/CSV
- [ ] Dashboard com gráficos interativos
- [ ] Sistema de tags

### [2.0.0] - Futuro
- [ ] API RESTful completa
- [ ] Aplicativo mobile
- [ ] Integração com terceiros
- [ ] Sistema de permissões granulares

---

## Como Usar Este Changelog

### Para Desenvolvedores
- Consulte este arquivo antes de atualizar o sistema
- Verifique as mudanças de breaking changes
- Leia as notas de migração quando aplicável

### Para Usuários
- Veja as novas funcionalidades adicionadas
- Conheça as melhorias implementadas
- Entenda o que mudou entre versões

---

## Versionamento

Este projeto segue [Semantic Versioning](https://semver.org/):

- **MAJOR** (X.0.0): Mudanças incompatíveis com versões anteriores
- **MINOR** (1.X.0): Novas funcionalidades mantendo compatibilidade
- **PATCH** (1.0.X): Correções de bugs

---

## Links Úteis

- [README Principal](README.md)
- [Guia de Deploy](DEPLOY.md)
- [Documentação Completa](INDICE_DOCUMENTACAO.md)

---

**Última atualização:** 15/01/2024
