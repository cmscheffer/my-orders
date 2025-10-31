# 🐧 Guia de Configuração WSL2 - Ubuntu

## ✅ Problema Resolvido

O erro de JavaScript foi causado por uma configuração incompleta do importmap. Agora a aplicação está configurada corretamente para usar:
- **Importmap Rails** (padrão do Rails 7.1)
- **jQuery via CDN** (jsDelivr)
- **Bootstrap 5.3 via CDN** (jsDelivr)
- **Turbo e Stimulus** para interatividade moderna

## 📋 O Que Foi Corrigido

### Commits Recentes:
1. **86626b2** - Configuração correta do importmap com jQuery e Bootstrap via CDN
2. **478eb12** - Remoção de arquivos conflitantes (importmap antigo)

### Arquivos Criados/Atualizados:
- ✅ `config/importmap.rb` - Configuração correta dos imports
- ✅ `app/javascript/application.js` - Entry point com jQuery e Bootstrap
- ✅ `app/javascript/controllers/application.js` - Configuração do Stimulus
- ✅ `app/javascript/controllers/index.js` - Carregamento de controllers

## 🚀 Como Testar no WSL2

### 1. Puxar as Últimas Alterações

No seu WSL2 Ubuntu, vá para o diretório do projeto e puxe as mudanças:

\`\`\`bash
cd ~/service_orders_app  # ou o caminho onde está seu projeto
git pull origin main
\`\`\`

### 2. Instalar Dependências (se necessário)

Se for a primeira vez rodando após pull, instale as gems:

\`\`\`bash
bundle install
\`\`\`

### 3. Iniciar o Servidor

\`\`\`bash
bin/rails server -b 0.0.0.0
\`\`\`

Ou simplesmente:

\`\`\`bash
rails s
\`\`\`

### 4. Acessar no Navegador

Abra no navegador Windows:

\`\`\`
http://localhost:3000
\`\`\`

## 🧪 Como Testar os Dropdowns

### Teste 1: Menu de Configurações (Admin)

1. Faça login com uma conta de **admin**
2. No navbar superior, clique em **"Configurações"** (ícone de engrenagem)
3. O dropdown deve abrir mostrando:
   - 👥 **Usuários**
   - 🏢 **Dados da Empresa**

### Teste 2: Menu de Usuário

1. No canto superior direito, clique no **nome do usuário**
2. O dropdown deve abrir mostrando:
   - 👤 **Meu Perfil**
   - 🚪 **Sair**

### Teste 3: Funcionalidade

- Clique em **Usuários** → Deve ir para `/users`
- Clique em **Dados da Empresa** → Deve ir para `/company_settings/edit`

## 🐛 Problemas Comuns e Soluções

### Erro: "Address already in use"

Se a porta 3000 já estiver em uso:

\`\`\`bash
# Encontrar processo usando porta 3000
lsof -ti:3000

# Matar processo
kill -9 $(lsof -ti:3000)

# Ou usar outra porta
rails s -p 3001
\`\`\`

### Dropdown Não Abre

Se o dropdown ainda não funcionar:

1. **Limpe o cache do navegador**:
   - Chrome/Edge: `Ctrl + Shift + Delete`
   - Selecione "Imagens e arquivos em cache"
   - Clique em "Limpar dados"

2. **Force refresh da página**:
   - Windows: `Ctrl + F5`
   - Linux: `Ctrl + Shift + R`

3. **Verifique o console do navegador**:
   - Pressione `F12`
   - Vá para aba **Console**
   - Veja se há erros JavaScript

### Erro de Migração do Banco

Se houver erros de banco de dados:

\`\`\`bash
# Recriar banco de dados
rails db:drop db:create db:migrate db:seed
\`\`\`

### Erro de Assets

Se CSS ou JavaScript não carregar:

\`\`\`bash
# Limpar assets e precompilar
rails assets:clobber
rails assets:precompile
\`\`\`

## 📊 Verificar Importmap

Para ver todos os imports configurados:

\`\`\`bash
bin/importmap json
\`\`\`

Você deve ver:
- ✅ `application`
- ✅ `@hotwired/turbo-rails`
- ✅ `@hotwired/stimulus`
- ✅ `jquery` (via CDN)
- ✅ `bootstrap` (via CDN)

## 🔍 Debug do JavaScript

Se precisar debugar o JavaScript:

1. Abra o navegador e pressione `F12`
2. Vá para aba **Console**
3. Digite no console:

\`\`\`javascript
// Verificar se jQuery está carregado
typeof jQuery  // Deve retornar "function"
typeof $       // Deve retornar "function"

// Verificar se Bootstrap está carregado
typeof bootstrap  // Deve retornar "object"

// Testar dropdown manualmente
new bootstrap.Dropdown(document.querySelector('[data-bs-toggle="dropdown"]'))
\`\`\`

## 📝 Logs do Servidor

Para ver logs em tempo real:

\`\`\`bash
# Em outro terminal WSL
tail -f log/development.log
\`\`\`

## ✨ Recursos Adicionais

### Turbo e Stimulus

A aplicação usa Turbo (para navegação SPA-like) e Stimulus (para JavaScript modular). Se precisar desabilitar Turbo em algum link:

\`\`\`erb
<%= link_to "Link sem Turbo", path, data: { turbo: false } %>
\`\`\`

### Bootstrap Componentes

Todos os componentes Bootstrap 5.3 devem funcionar:
- Dropdowns ✅
- Modals
- Tooltips
- Popovers
- Toasts
- Alerts

## 🆘 Precisa de Ajuda?

Se ainda tiver problemas:

1. Cole o erro completo do console do navegador
2. Cole o log do servidor Rails
3. Informe qual navegador está usando
4. Diga em qual parte específica o dropdown não funciona

## 📚 Documentação Relevante

- [Importmap Rails](https://github.com/rails/importmap-rails)
- [Bootstrap 5.3 Dropdowns](https://getbootstrap.com/docs/5.3/components/dropdowns/)
- [Turbo Rails](https://turbo.hotwired.dev/)
- [Stimulus](https://stimulus.hotwired.dev/)
