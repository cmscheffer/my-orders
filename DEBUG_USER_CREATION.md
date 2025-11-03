# 🔍 Guia de Debug - Criação de Usuário

## 📋 Problema
Usuário não está sendo criado através do formulário web.

## 🧪 Como Verificar o Erro

### Opção 1: Via Console Rails (Recomendado)

```bash
# No diretório do projeto
cd /home/cassio/projetos/my-orders

# Abrir console Rails
rails console
# ou
bundle exec rails console
```

Depois execute no console:

```ruby
# Teste com senha FRACA (deve falhar)
user = User.new(
  name: "Teste Silva",
  email: "teste@teste.com",
  password: "123456",
  password_confirmation: "123456",
  role: "user"
)

user.valid?  # Deve retornar false
user.errors.full_messages  # Mostra os erros

# Teste com senha FORTE (deve funcionar)
user2 = User.new(
  name: "Teste Silva",
  email: "teste2@teste.com",
  password: "Senha@123",
  password_confirmation: "Senha@123",
  role: "user"
)

user2.valid?  # Deve retornar true
user2.save   # Deve salvar
user2.id     # Deve ter um ID

# Limpar teste
user2.destroy if user2.persisted?
```

### Opção 2: Via Script Automático

```bash
# No diretório do projeto
cd /home/cassio/projetos/my-orders

# Executar script de teste
rails runner test_user_creation.rb
# ou
bundle exec rails runner test_user_creation.rb
```

### Opção 3: Via Formulário Web + Logs

1. **Abrir terminal com logs do servidor**:
```bash
cd /home/cassio/projetos/my-orders
tail -f log/development.log
```

2. **Em outro terminal, iniciar servidor** (se não estiver rodando):
```bash
cd /home/cassio/projetos/my-orders
rails server
# ou
bundle exec rails server
```

3. **Acessar formulário**:
   - Abra: http://localhost:3000/users/new
   - Preencha com dados de teste:
     - Nome: João Teste
     - Email: joao@teste.com
     - Senha: Senha@123
     - Confirmar Senha: Senha@123
     - Papel: Usuário

4. **Clicar em "Criar Usuário"**

5. **Verificar logs** no terminal (tail -f log/development.log):
   - Procure por linhas com "🔍 DEBUG - Criando usuário"
   - Veja os erros detalhados se houver

## 🎯 Requisitos de Senha

A senha DEVE ter TODOS estes requisitos:

1. ✅ **Mínimo 6 caracteres**
2. ✅ **Pelo menos 1 letra maiúscula** (A-Z)
3. ✅ **Pelo menos 1 número** (0-9)
4. ✅ **Pelo menos 1 caractere especial** (!@#$%^&*()_+-=[]{}; etc)

### ✅ Senhas Válidas (exemplos):
- `Senha@123`
- `Admin#2024`
- `User!Pass1`
- `Test@2024`
- `Strong#Pass9`

### ❌ Senhas Inválidas (exemplos):
- `123456` - falta maiúscula e especial
- `senha123` - falta maiúscula e especial
- `Senha123` - falta caractere especial
- `SENHA@` - falta número
- `senha@1` - falta maiúscula

## 📊 O Que os Logs Devem Mostrar

### Se houver erro de validação:
```
🔍 DEBUG - Criando usuário
Params recebidos: {...}
User params filtrados: {...}
Usuário antes de salvar:
  - Name: João Teste
  - Email: joao@teste.com
  - Role: user
  - Password presente? true
  - Password length: 9
Validando usuário...
Erros de validação:
  - password: deve conter pelo menos uma letra maiúscula
  - password: deve conter pelo menos um caractere especial
❌ FALHA ao criar usuário
Total de erros: 2
```

### Se salvar com sucesso:
```
🔍 DEBUG - Criando usuário
Params recebidos: {...}
Validando usuário...
Erros de validação: (vazio)
✅ Usuário criado com sucesso! ID: 123
```

## 🔧 Comandos Úteis

```bash
# Ver últimas 50 linhas do log
tail -50 log/development.log

# Ver log em tempo real
tail -f log/development.log

# Limpar logs
echo "" > log/development.log

# Verificar usuários existentes
rails console
User.count
User.last
User.pluck(:email)

# Deletar usuário de teste
rails console
User.find_by(email: 'teste@teste.com')&.destroy
```

## 📞 Reporte o Erro

Se o erro persistir, copie e cole aqui:

1. **Mensagem de erro da tela** (alerta vermelho)
2. **Logs do servidor** (últimas 50 linhas)
3. **Dados que tentou criar** (sem a senha real)
4. **Resultado do teste no console** (Opção 1)

Exemplo:
```
Tentei criar:
- Nome: João Silva
- Email: joao@teste.com
- Senha: (9 caracteres, tem maiúscula, número e especial)
- Papel: Usuário

Erro na tela:
"❌ Falha ao criar usuário! 2 erros encontrados"
- Password deve conter...
- Password deve conter...

Logs do servidor:
(colar últimas linhas do log aqui)

Teste no console:
user.valid? retornou false
user.errors.full_messages retornou [...]
```
