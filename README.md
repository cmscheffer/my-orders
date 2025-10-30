# Sistema de Ordens de Serviço 🛠️

Sistema web completo para gerenciamento de ordens de serviço desenvolvido em **Ruby on Rails** com arquitetura **MVC** e autenticação de usuários.

## 📋 Índice

- [Características](#características)
- [Tecnologias Utilizadas](#tecnologias-utilizadas)
- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Configuração](#configuração)
- [Uso](#uso)
- [Funcionalidades](#funcionalidades)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Deploy](#deploy)
- [Credenciais Padrão](#credenciais-padrão)
- [Contribuindo](#contribuindo)
- [Licença](#licença)

## ✨ Características

- ✅ **Autenticação completa** com Devise (login, registro, recuperação de senha)
- ✅ **Sistema de permissões** (usuário comum e administrador)
- ✅ **CRUD completo** de ordens de serviço
- ✅ **Cadastro de técnicos** com especialidades e vincular a ordens
- ✅ **Catálogo de peças** para seleção em ordens de serviço
- ✅ **Gestão financeira** com valores de serviço, peças e totais
- ✅ **Informações de equipamento** (nome, marca, modelo, número de série)
- ✅ **Dashboard** com estatísticas e métricas
- ✅ **Filtros avançados** por status, prioridade, técnico
- ✅ **Gestão de status** (Pendente, Em Andamento, Concluída, Cancelada)
- ✅ **Níveis de prioridade** (Baixa, Média, Alta, Urgente)
- ✅ **Alertas de atraso** para ordens vencidas
- ✅ **Interface responsiva** com Bootstrap 5
- ✅ **Arquitetura MVC** seguindo as melhores práticas do Rails
- ✅ **Internacionalização** (pt-BR)

## 🛠️ Tecnologias Utilizadas

- **Ruby** 3.2+
- **Rails** 7.1+
- **SQLite3** (desenvolvimento) / **PostgreSQL** (produção recomendado)
- **Devise** - Autenticação
- **Bootstrap 5** - Interface UI
- **Turbo & Stimulus** - Interatividade
- **SCSS** - Estilos customizados
- **Prawn** - Geração de PDF
- **Prawn-Table** - Tabelas em PDF
- **Chart.js** - Gráficos e visualizações

## 📦 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- Ruby 3.2 ou superior
- Rails 7.1 ou superior
- SQLite3 (desenvolvimento)
- PostgreSQL (produção - opcional)
- Node.js e Yarn (para gerenciamento de assets)
- Git

### Instalação do Ruby (via rbenv)

```bash
# Instalar rbenv
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-installer | bash

# Instalar Ruby 3.2.0
rbenv install 3.2.0
rbenv global 3.2.0

# Verificar instalação
ruby -v
```

### Instalação do Rails

```bash
gem install rails
rails -v
```

## 🚀 Instalação

### Opção 1: Script de Instalação Automática

```bash
# Clone o repositório
git clone <url-do-repositorio>
cd service_orders_app

# Execute o script de instalação
chmod +x INSTALL.sh
./INSTALL.sh
```

### Opção 2: Instalação Manual

```bash
# Clone o repositório
git clone <url-do-repositorio>
cd service_orders_app

# Instale as dependências
bundle install

# Configure o banco de dados
rails db:create
rails db:migrate

# Popule o banco (opcional - dados de exemplo)
rails db:seed

# Inicie o servidor
rails server
```

Acesse http://localhost:3000

## ⚙️ Configuração

### Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto:

```bash
# Database
DATABASE_URL=postgresql://user:password@localhost/service_orders_production

# Secret Key Base (gere com: rails secret)
SECRET_KEY_BASE=sua_chave_secreta_aqui

# Email Configuration (para recuperação de senha)
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_DOMAIN=example.com
SMTP_USERNAME=seu_email@gmail.com
SMTP_PASSWORD=sua_senha_app
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
```

### Configuração de Email (Opcional)

Edite `config/environments/production.rb`:

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address:              ENV['SMTP_ADDRESS'],
  port:                 ENV['SMTP_PORT'],
  domain:               ENV['SMTP_DOMAIN'],
  user_name:            ENV['SMTP_USERNAME'],
  password:             ENV['SMTP_PASSWORD'],
  authentication:       ENV['SMTP_AUTHENTICATION'],
  enable_starttls_auto: ENV['SMTP_ENABLE_STARTTLS_AUTO']
}
```

## 📖 Uso

### Acessando o Sistema

1. Abra o navegador e acesse http://localhost:3000
2. Faça login com as credenciais padrão ou crie uma conta
3. Navegue pelo dashboard para visualizar as estatísticas
4. Crie, edite e gerencie ordens de serviço

### Comandos Úteis

```bash
# Iniciar servidor de desenvolvimento
rails server
# ou
rails s

# Console do Rails
rails console
# ou
rails c

# Executar testes
rails test

# Ver rotas
rails routes

# Resetar banco de dados
rails db:reset

# Criar nova migration
rails generate migration AddColumnToTable

# Gerar controller
rails generate controller ControllerName

# Gerar model
rails generate model ModelName
```

## 🎯 Funcionalidades

### Autenticação
- ✅ Registro de novos usuários
- ✅ Login/Logout
- ✅ Recuperação de senha
- ✅ Edição de perfil
- ✅ Sistema de roles (User/Admin)

### Dashboard
- 📊 Total de ordens de serviço
- 📊 Ordens pendentes
- 📊 Ordens em andamento
- 📊 Ordens concluídas
- 📊 Ordens canceladas
- ⚠️ Alertas de ordens atrasadas
- 📋 Listagem de ordens recentes

### Ordens de Serviço
- ➕ Criar nova ordem
- ✏️ Editar ordem existente
- 🗑️ Excluir ordem
- 👁️ Visualizar detalhes
- ✅ Marcar como concluída
- ❌ Cancelar ordem
- 🔍 Filtrar por status
- 🔍 Filtrar por prioridade
- 📅 Data de vencimento
- 👤 Informações do cliente
- 🖥️ Dados do equipamento (nome, marca, modelo, número de série)
- 👨‍🔧 Atribuição de técnico responsável
- 🔧 Seleção de peças utilizadas
- 💰 Gestão financeira (valor do serviço, peças, desconto, total)
- 💳 Status e método de pagamento
- 📄 **Geração de PDF profissional** com todas as informações da ordem

### Cadastro de Técnicos
- ➕ Adicionar novos técnicos
- ✏️ Editar informações do técnico
- 👁️ Ver detalhes e estatísticas
- 🔄 Ativar/desativar técnico
- 🔍 Filtrar por especialidade
- 🔍 Buscar por nome/email
- 📊 Ver ordens de serviço do técnico
- 🎓 13 especialidades disponíveis (Hardware, Software, Redes, etc.)
- 👤 Vincular técnico a usuário do sistema (opcional)

### Catálogo de Peças
- ➕ Cadastrar novas peças
- ✏️ Editar informações da peça
- 🗑️ Excluir peças não utilizadas
- 🔄 Ativar/desativar peças
- 📦 Controle de estoque (quantidade e mínimo)
- 💰 Preço unitário
- 🏷️ Categorização (Hardware, Periféricos, Consumíveis, etc.)
- 🔍 Filtros por categoria e status
- ⚠️ Alertas de estoque baixo
- 🔢 Código automático gerado

### Geração de PDF
- 📄 PDF profissional formato A4
- 📋 Todas as informações da ordem incluídas
- 💰 Valores formatados em R$ (padrão brasileiro)
- 📅 Datas em português
- 📊 Tabela de peças com totais
- 💵 Resumo financeiro completo
- ✍️ Espaço para assinatura do cliente
- 🖨️ Pronto para impressão
- 📧 Fácil de enviar por email
- 🔗 Geração com um clique (botão ou ícone)
- 📱 Compatível com desktop, tablet e mobile

### Relatórios e Análises
- 📊 **Relatório de Ordens Concluídas** completo e interativo
- 🔍 **Filtros avançados:**
  - Por técnico específico
  - Por período (data inicial e final)
  - Combinação de múltiplos filtros
- 📈 **Estatísticas em tempo real:**
  - Total de ordens e receita
  - Ticket médio
  - Taxa de pagamento
  - Análise financeira detalhada
- 👨‍🔧 **Análise por técnico** (ordens concluídas por cada técnico)
- 🔧 **Top 5 peças mais utilizadas** com quantidade e receita
- 📊 **Gráficos visuais** (Chart.js):
  - Status de pagamento (pizza)
  - Evolução temporal
- 📄 **Exportação para PDF** (formato landscape)
- 💰 **Totalizadores** em todas as tabelas
- 🎨 Interface responsiva e intuitiva
- 📱 Visualização otimizada para todos os dispositivos

### Status Disponíveis
- 🟡 **Pendente** - Ordem aguardando início
- 🔵 **Em Andamento** - Ordem sendo executada
- 🟢 **Concluída** - Ordem finalizada
- ⚫ **Cancelada** - Ordem cancelada

### Níveis de Prioridade
- ⚪ **Baixa** - Sem urgência
- 🔵 **Média** - Prioridade normal
- 🟡 **Alta** - Requer atenção
- 🔴 **Urgente** - Máxima prioridade

### Permissões

**Usuário Comum:**
- Ver suas próprias ordens de serviço
- Criar novas ordens
- Editar/excluir apenas suas ordens
- Marcar suas ordens como concluídas
- Cancelar suas ordens

**Administrador:**
- Ver todas as ordens de serviço
- Editar/excluir qualquer ordem
- Gerenciar todos os usuários
- Acesso completo ao sistema

## 📁 Estrutura do Projeto

```
service_orders_app/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   ├── dashboard_controller.rb
│   │   ├── service_orders_controller.rb
│   │   ├── parts_controller.rb
│   │   └── technicians_controller.rb
│   ├── models/
│   │   ├── user.rb
│   │   ├── service_order.rb
│   │   ├── service_order_part.rb
│   │   ├── part.rb
│   │   └── technician.rb
│   ├── views/
│   │   ├── layouts/
│   │   │   ├── application.html.erb
│   │   │   ├── _navbar.html.erb
│   │   │   └── _flash_messages.html.erb
│   │   ├── dashboard/
│   │   │   └── index.html.erb
│   │   ├── service_orders/
│   │   │   ├── index.html.erb
│   │   │   ├── show.html.erb
│   │   │   ├── _form.html.erb
│   │   │   └── _parts_fields.html.erb
│   │   ├── parts/
│   │   │   ├── index.html.erb
│   │   │   ├── show.html.erb
│   │   │   └── _form.html.erb
│   │   └── technicians/
│   │       ├── index.html.erb
│   │       ├── show.html.erb
│   │       └── _form.html.erb
│   │   └── devise/
│   │       ├── sessions/
│   │       └── registrations/
│   └── assets/
│       └── stylesheets/
│           └── application.scss
├── config/
│   ├── routes.rb
│   ├── database.yml
│   ├── application.rb
│   ├── initializers/
│   │   └── devise.rb
│   └── locales/
│       └── pt-BR.yml
├── db/
│   ├── migrate/
│   │   ├── 20240101000001_devise_create_users.rb
│   │   ├── 20240101000002_create_service_orders.rb
│   │   ├── 20240101000003_add_equipment_to_service_orders.rb
│   │   ├── 20240101000004_add_financial_fields_to_service_orders.rb
│   │   ├── 20240101000005_create_parts.rb
│   │   ├── 20240101000006_create_service_order_parts.rb
│   │   ├── 20240101000007_create_technicians.rb
│   │   └── 20240101000008_add_technician_to_service_orders.rb
│   └── seeds.rb
├── Gemfile
├── Gemfile.lock
├── INSTALL.sh
└── README.md
```

## 🚢 Deploy

### Heroku

```bash
# Criar app no Heroku
heroku create nome-do-app

# Adicionar PostgreSQL
heroku addons:create heroku-postgresql:mini

# Configurar variáveis de ambiente
heroku config:set RAILS_ENV=production
heroku config:set SECRET_KEY_BASE=$(rails secret)

# Deploy
git push heroku main

# Executar migrations
heroku run rails db:migrate

# Popular banco (opcional)
heroku run rails db:seed

# Abrir app
heroku open
```

### Railway

```bash
# Instalar Railway CLI
npm install -g @railway/cli

# Login
railway login

# Criar projeto
railway init

# Deploy
railway up

# Executar migrations
railway run rails db:migrate

# Configurar domínio
railway domain
```

### Render

1. Conecte seu repositório GitHub ao Render
2. Configure o serviço:
   - **Build Command:** `bundle install; rails db:migrate`
   - **Start Command:** `bundle exec puma -C config/puma.rb`
3. Adicione variáveis de ambiente
4. Deploy automático a cada push

### VPS (Ubuntu/Debian)

```bash
# Instalar dependências
sudo apt update
sudo apt install ruby-full postgresql nodejs npm

# Clonar repositório
git clone <url-do-repositorio>
cd service_orders_app

# Instalar gems
bundle install --deployment --without development test

# Configurar banco de dados
RAILS_ENV=production rails db:create db:migrate

# Pré-compilar assets
RAILS_ENV=production rails assets:precompile

# Configurar Nginx + Passenger ou usar Puma
# ...

# Iniciar serviço
RAILS_ENV=production rails server -b 0.0.0.0
```

## 🔐 Credenciais Padrão

Após executar `rails db:seed`, as seguintes contas estarão disponíveis:

**Administrador:**
- Email: `admin@example.com`
- Senha: `123456`

**Usuários:**
- Email: `joao@example.com` | Senha: `123456`
- Email: `maria@example.com` | Senha: `123456`

**Técnicos cadastrados:**
- Carlos Alberto (Hardware) - vinculado a joao@example.com
- Fernanda Costa (Redes) - vinculada a maria@example.com
- Roberto Silva (Software)
- Ana Paula (Impressoras)
- Marcos Oliveira (Notebooks) - Inativo

**Peças cadastradas:**
- 10 peças de exemplo (Memória RAM, SSD, HD, etc.)

**Ordens de Serviço:**
- 7 ordens de exemplo com diferentes status e técnicos atribuídos

⚠️ **IMPORTANTE:** Altere estas senhas em produção!

## 🔒 Segurança

### Recomendações para Produção

1. **Altere todas as senhas padrão**
2. **Configure SECRET_KEY_BASE** adequadamente
3. **Use HTTPS** em produção
4. **Configure CORS** se necessário
5. **Implemente rate limiting**
6. **Mantenha as gems atualizadas:**
   ```bash
   bundle update
   ```
7. **Configure backups automáticos** do banco de dados
8. **Use variáveis de ambiente** para dados sensíveis
9. **Ative logs de auditoria**
10. **Configure SSL** para o banco de dados

## 🧪 Testes

```bash
# Executar todos os testes
rails test

# Executar testes de models
rails test:models

# Executar testes de controllers
rails test:controllers

# Executar testes de sistema
rails test:system
```

## 🐛 Troubleshooting

### Erro: "Webpacker can't find application"

```bash
rails webpacker:install
rails webpacker:compile
```

### Erro: "PG::ConnectionBad"

Verifique as credenciais do PostgreSQL em `config/database.yml`

### Erro: "LoadError: cannot load such file -- devise"

```bash
bundle install
```

### Assets não carregam em produção

```bash
RAILS_ENV=production rails assets:precompile
```

## 🤝 Contribuindo

Contribuições são bem-vindas! Para contribuir:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📝 Roadmap

Funcionalidades planejadas:

- [ ] Sistema de comentários nas ordens
- [ ] Upload de arquivos/anexos
- [ ] Notificações por email
- [ ] Relatórios em PDF
- [ ] API RESTful
- [ ] Dashboard com gráficos
- [ ] Histórico de alterações
- [ ] Sistema de tags
- [ ] Busca avançada
- [ ] Exportação para Excel/CSV

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 👨‍💻 Autor

Desenvolvido com ❤️ usando Ruby on Rails

## 📞 Suporte

Para suporte, envie um email para suporte@example.com ou abra uma issue no GitHub.

---

**Desenvolvido com Ruby on Rails 💎**
