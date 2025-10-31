# 🏗️ Arquitetura do Sistema

## 📋 Visão Geral

Sistema de Gerenciamento de Ordens de Serviço desenvolvido em Ruby on Rails 7.1 com foco em segurança, performance e usabilidade.

## 🛠️ Stack Tecnológica

### Backend
- **Ruby**: 3.2.0
- **Rails**: 7.1.6
- **Database**: 
  - SQLite3 (desenvolvimento/test)
  - PostgreSQL (produção - Heroku)

### Frontend
- **CSS Framework**: Bootstrap 5.3.2 (via CDN)
- **JavaScript**: 
  - Hotwired Turbo (navegação SPA-like)
  - Hotwired Stimulus (controllers JavaScript)
  - jQuery 3.7.1 (via CDN)
- **Assets Pipeline**: 
  - Sprockets (CSS e JavaScript utilitários)
  - Importmap (Turbo e Stimulus)

### Gems Principais
- **devise**: Autenticação de usuários
- **prawn** & **prawn-table**: Geração de PDFs
- **rack-attack**: Proteção contra DDoS e brute force
- **secure_headers**: Headers de segurança HTTP
- **bootstrap**: Framework CSS
- **jquery-rails**: jQuery para componentes Bootstrap

## 📁 Estrutura de Diretórios

```
service_orders_app/
├── app/
│   ├── assets/
│   │   ├── config/
│   │   │   └── manifest.js              # Configuração Sprockets
│   │   ├── javascripts/
│   │   │   └── dropdowns.js             # Inicialização Bootstrap dropdowns
│   │   └── stylesheets/
│   │       └── application.scss         # Estilos principais
│   ├── controllers/
│   │   ├── service_orders_controller.rb
│   │   ├── users_controller.rb
│   │   ├── parts_controller.rb
│   │   ├── technicians_controller.rb
│   │   └── reports_controller.rb
│   ├── javascript/
│   │   ├── application.js               # Importmap entry point
│   │   └── controllers/                 # Stimulus controllers
│   ├── models/
│   │   ├── user.rb
│   │   ├── service_order.rb
│   │   ├── part.rb
│   │   └── technician.rb
│   ├── services/
│   │   ├── service_order_pdf_generator.rb
│   │   └── completed_orders_report_pdf.rb
│   └── views/
│       └── layouts/
│           ├── application.html.erb     # Layout principal
│           └── _navbar.html.erb         # Navegação
├── config/
│   ├── environments/
│   │   ├── development.rb
│   │   ├── production.rb
│   │   └── test.rb
│   ├── initializers/
│   │   ├── assets.rb                    # Configuração assets
│   │   ├── devise.rb
│   │   ├── rack_attack.rb               # Rate limiting
│   │   └── secure_headers.rb            # CSP e headers HTTP
│   ├── importmap.rb                     # Importmap configuration
│   └── routes.rb
├── db/
│   ├── migrate/
│   └── schema.rb
├── public/
│   └── favicon.svg
└── Procfile                              # Configuração Heroku
```

## 🎨 Sistema de Assets

### Abordagem Híbrida

O projeto usa uma abordagem híbrida para assets, combinando o melhor de Sprockets e Importmap:

#### Sprockets (app/assets/)
- **CSS**: Todos os estilos (Bootstrap SASS, custom CSS)
- **JavaScript Utilitário**: dropdowns.js para inicialização Bootstrap
- **Imagens**: Logos, favicons, etc.

**Por que Sprockets para dropdowns?**
- Maior compatibilidade com Bootstrap 5
- Evita problemas de cache do importmap
- Mais confiável para JavaScript que manipula DOM

#### Importmap (app/javascript/)
- **Turbo Rails**: Navegação SPA-like
- **Stimulus**: Controllers JavaScript modulares
- **Controllers**: Lógica JavaScript organizada

#### CDN (via &lt;script&gt; tags)
- **jQuery 3.7.1**: Dependência do Bootstrap
- **Popper.js 2.11.8**: Posicionamento de dropdowns/tooltips
- **Bootstrap 5.3.2 Bundle**: Framework completo com Popper incluído

**Por que CDN?**
- Carregamento mais rápido (cache do navegador)
- Menos assets para compilar
- Integridade SHA256 para segurança
- Funciona perfeitamente com Turbo

## 🔒 Segurança

### Content Security Policy (CSP)

Configurado em `config/initializers/secure_headers.rb`:

```ruby
config.csp = {
  default_src: %w['self'],
  script_src: %w['self' 'unsafe-inline' https://cdn.jsdelivr.net],
  style_src: %w['self' 'unsafe-inline' https://cdn.jsdelivr.net],
  img_src: %w['self' data: https:],
  font_src: %w['self' data: https://cdn.jsdelivr.net],
  connect_src: %w['self' https://cdn.jsdelivr.net],
  frame_ancestors: %w['none'],
  upgrade_insecure_requests: true
}
```

### Rate Limiting (Rack::Attack)

Configurado em `config/initializers/rack_attack.rb`:

- **300 requisições/minuto** por IP (geral)
- **5 tentativas de login/20 segundos** por IP
- **Bloqueio de user-agents suspeitos**
- **Whitelist para localhost** (desenvolvimento)

### Outros Headers de Segurança

- **HSTS**: Force HTTPS por 1 ano
- **X-Frame-Options**: DENY (previne clickjacking)
- **X-Content-Type-Options**: nosniff
- **X-XSS-Protection**: 1; mode=block
- **Referrer-Policy**: strict-origin-when-cross-origin

## 🚀 Deploy

### Desenvolvimento (WSL2/Ubuntu)

```bash
# Instalar dependências
bundle install

# Setup banco de dados
rails db:migrate db:seed

# Iniciar servidor
rails server
```

### Produção (Heroku)

```bash
# Fazer deploy
git push heroku main

# Rodar migrações
heroku run rails db:migrate

# Ver logs
heroku logs --tail
```

**Configuração Heroku:**
- `Procfile` configura Puma web server
- PostgreSQL como banco de dados
- `config.force_ssl = true` em produção
- Assets precompilados automaticamente

## 🎯 Funcionalidades Principais

### Gestão de Ordens de Serviço
- CRUD completo
- Upload de logo da empresa
- Geração de PDF profissional
- Filtros por status e prioridade
- Cálculo automático de valores

### Gestão de Usuários
- Sistema de autenticação (Devise)
- Controle de permissões (admin/user)
- CRUD completo (somente admin)
- Perfil de usuário

### Relatórios
- Relatório de ordens concluídas
- Filtro por período e cliente
- Estatísticas financeiras
- Exportação em PDF

### Cadastros Auxiliares
- Peças (estoque)
- Técnicos
- Dados da empresa (com logo)

## 📊 Banco de Dados

### Principais Tabelas

- **users**: Usuários do sistema
- **service_orders**: Ordens de serviço
- **parts**: Peças utilizadas
- **technicians**: Técnicos disponíveis
- **company_settings**: Configurações da empresa

### Relacionamentos

```
User (1) ---< (N) ServiceOrder
ServiceOrder (N) >---< (N) Part
ServiceOrder (N) >--- (1) Technician
```

## 🧪 Testes

```bash
# Rodar todos os testes
rails test

# Testar controllers específicos
rails test test/controllers/service_orders_controller_test.rb
```

## 📝 Convenções de Código

### Ruby/Rails
- Seguir [Ruby Style Guide](https://rubystyle.guide/)
- Usar nomes descritivos em português para modelos de negócio
- Controllers RESTful
- Services para lógica complexa (ex: geração de PDF)

### JavaScript
- Usar `const` por padrão, `let` quando necessário
- Evitar `var`
- Comentários em português
- IIFE para escopo isolado quando apropriado

### CSS/SCSS
- Seguir metodologia BEM quando possível
- Classes utilitárias do Bootstrap
- Custom CSS em `application.scss`

## 🔧 Troubleshooting

### Dropdowns não funcionam

Os dropdowns são inicializados manualmente em `app/assets/javascripts/dropdowns.js`. Se não funcionarem:

1. Verificar se Bootstrap está carregado: `typeof bootstrap` no console
2. Verificar se dropdowns.js foi carregado
3. Limpar cache de assets: `rm -rf tmp/cache`
4. Reiniciar servidor

### Erros de CSP

Se houver erros de Content Security Policy no console:

1. Verificar `config/initializers/secure_headers.rb`
2. Adicionar domínio necessário às diretivas apropriadas
3. Reiniciar servidor (mudanças em initializers requerem restart)

### Assets não carregam

```bash
# Limpar cache
rails assets:clobber

# Precompilar assets
rails assets:precompile

# Verificar manifest.js
cat app/assets/config/manifest.js
```

## 📚 Documentação Adicional

- [README.md](README.md) - Visão geral do projeto
- [WSL2_SETUP.md](WSL2_SETUP.md) - Setup em Windows com WSL2
- [DEPLOY.md](DEPLOY.md) - Guia de deploy para Heroku
- [API_EXAMPLES.md](API_EXAMPLES.md) - Exemplos de uso da API

## 🤝 Contribuindo

1. Criar branch para feature: `git checkout -b feature/nova-funcionalidade`
2. Fazer commits descritivos em português
3. Testar localmente
4. Criar Pull Request

## 📄 Licença

© 2024 Sistema de Ordens de Serviço. Todos os direitos reservados.
