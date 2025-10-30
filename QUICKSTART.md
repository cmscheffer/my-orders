# 🚀 Guia Rápido de Início

Este guia vai te ajudar a colocar o sistema rodando em **5 minutos**!

## Pré-requisitos

- Ruby 3.2+ instalado
- SQLite3 instalado

## Instalação Rápida

### 1. Clone o repositório

```bash
git clone <url-do-repositorio>
cd service_orders_app
```

### 2. Instale as dependências

```bash
bundle install
```

### 3. Configure o banco de dados

```bash
rails db:create
rails db:migrate
rails db:seed
```

### 4. Inicie o servidor

```bash
rails server
```

### 5. Acesse o sistema

Abra seu navegador em: **http://localhost:3000**

## 🔐 Login

Use uma das contas padrão:

**Admin:**
- Email: `admin@example.com`
- Senha: `123456`

**Usuário:**
- Email: `joao@example.com`
- Senha: `123456`

## 📋 Primeiros Passos

1. **Login** - Acesse com uma das contas acima
2. **Dashboard** - Visualize as estatísticas
3. **Nova OS** - Clique em "Nova OS" no menu
4. **Preencha o formulário**:
   - Título: "Minha primeira ordem"
   - Descrição: "Teste do sistema"
   - Status: Pendente
   - Prioridade: Média
5. **Salvar** - Clique em "Create Service order"
6. **Visualizar** - Veja a ordem criada

## 🎯 Funcionalidades Principais

### Dashboard
- Estatísticas gerais
- Ordens recentes
- Alertas de atraso

### Ordens de Serviço
- Criar nova ordem
- Listar todas as ordens
- Filtrar por status/prioridade
- Editar ordem
- Marcar como concluída
- Cancelar ordem

### Perfil
- Editar nome e email
- Alterar senha
- Gerenciar conta

## 🛠️ Comandos Úteis

```bash
# Ver rotas disponíveis
rails routes

# Acessar console do Rails
rails console

# Resetar banco de dados
rails db:reset

# Ver logs em tempo real
tail -f log/development.log
```

## 🐛 Problemas Comuns

### Erro de Bundle

```bash
bundle install
```

### Erro de Database

```bash
rails db:drop db:create db:migrate db:seed
```

### Porta 3000 ocupada

```bash
# Use outra porta
rails server -p 3001
```

## 📚 Próximos Passos

1. Explore o código em `app/`
2. Leia o README.md completo
3. Customize as views em `app/views/`
4. Adicione suas próprias funcionalidades

## 💡 Dicas

- Os arquivos principais estão em `app/controllers/` e `app/models/`
- As views usam Bootstrap 5 para estilização
- O sistema está em português (pt-BR)
- Todos os dados de teste podem ser resetados com `rails db:reset`

## 🆘 Precisa de Ajuda?

- Consulte o README.md completo
- Veja a documentação do Rails: https://guides.rubyonrails.org
- Abra uma issue no GitHub

---

**Pronto! Agora você já pode começar a usar o sistema! 🎉**
