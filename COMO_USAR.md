# 📖 Como Usar Este Projeto

Este arquivo explica como usar este código Ruby on Rails que foi fornecido.

## ⚠️ IMPORTANTE: Este projeto NÃO ESTÁ RODANDO

O código foi fornecido completo, mas **você precisa instalá-lo e executá-lo** em sua máquina ou servidor.

---

## 🎯 O Que Você Recebeu

Você recebeu um projeto completo Ruby on Rails com:

- ✅ 41 arquivos de código fonte
- ✅ Modelos, Controllers e Views completos
- ✅ Sistema de autenticação configurado
- ✅ Banco de dados estruturado
- ✅ Interface Bootstrap completa
- ✅ Documentação detalhada

**PORÉM:** O código está em arquivos, não está executando!

---

## 🚀 Como Colocar para Rodar

### Passo 1: Pré-requisitos

Você precisa instalar em sua máquina:

1. **Ruby 3.2 ou superior**
   ```bash
   # Verificar se tem Ruby instalado
   ruby -v
   
   # Se não tiver, instale:
   # Mac: brew install ruby
   # Ubuntu: sudo apt install ruby-full
   # Windows: https://rubyinstaller.org/
   ```

2. **Rails 7.1 ou superior**
   ```bash
   gem install rails
   rails -v
   ```

3. **SQLite3**
   ```bash
   # Mac: já vem instalado
   # Ubuntu: sudo apt install sqlite3
   # Windows: vem com RubyInstaller
   ```

4. **Git** (para baixar o código)
   ```bash
   git --version
   ```

### Passo 2: Baixar os Arquivos

**Opção A: Se está em um repositório Git**
```bash
git clone <url-do-repositorio>
cd service_orders_app
```

**Opção B: Se recebeu os arquivos**
- Extraia o ZIP ou copie os arquivos
- Abra o terminal na pasta do projeto

### Passo 3: Instalar Dependências

```bash
# Instalar todas as gems necessárias
bundle install
```

**Tempo estimado:** 3-5 minutos (depende da internet)

### Passo 4: Configurar Banco de Dados

```bash
# Criar banco de dados
rails db:create

# Executar migrations (criar tabelas)
rails db:migrate

# Popular com dados de exemplo (OPCIONAL)
rails db:seed
```

### Passo 5: Iniciar o Servidor

```bash
# Iniciar servidor de desenvolvimento
rails server
```

Você verá algo como:
```
=> Booting Puma
=> Rails 7.1.0 application starting in development
=> Run `bin/rails server --help` for more startup options
Puma starting in single mode...
* Listening on http://127.0.0.1:3000
```

### Passo 6: Acessar no Navegador

Abra seu navegador e acesse:
```
http://localhost:3000
```

---

## 🔐 Primeiras Credenciais

Se você executou `rails db:seed`, pode fazer login com:

**Administrador:**
- Email: `admin@example.com`
- Senha: `123456`

**Usuário:**
- Email: `joao@example.com`
- Senha: `123456`

Se **NÃO** executou seed, clique em "Criar conta" e registre-se.

---

## 🛠️ Comandos Úteis

```bash
# Parar o servidor
# Pressione Ctrl+C no terminal

# Reiniciar servidor
rails server

# Limpar e recriar banco de dados
rails db:reset

# Ver rotas disponíveis
rails routes

# Console interativo do Rails
rails console

# Ver logs
tail -f log/development.log
```

---

## 📂 Estrutura dos Arquivos

```
service_orders_app/
├── app/                    # Código principal da aplicação
│   ├── controllers/        # Lógica de controle
│   ├── models/            # Modelos de dados
│   ├── views/             # Templates HTML
│   └── assets/            # CSS, JS, imagens
├── config/                # Configurações
│   ├── routes.rb          # Rotas da aplicação
│   └── database.yml       # Configuração do banco
├── db/                    # Banco de dados
│   ├── migrate/           # Migrations
│   └── seeds.rb           # Dados iniciais
├── Gemfile                # Dependências Ruby
└── README.md              # Documentação principal
```

---

## 🎯 Próximos Passos

1. **Explore o sistema:**
   - Faça login
   - Crie uma ordem de serviço
   - Teste os filtros
   - Veja o dashboard

2. **Leia a documentação:**
   - `README.md` - Documentação completa
   - `QUICKSTART.md` - Guia rápido
   - `PROJECT_SUMMARY.md` - Resumo técnico

3. **Customize:**
   - Edite as views em `app/views/`
   - Modifique estilos em `app/assets/stylesheets/`
   - Adicione novas funcionalidades

4. **Faça deploy:**
   - Leia `DEPLOY.md` para publicar na internet

---

## ❓ Problemas Comuns

### "command not found: bundle"
```bash
gem install bundler
```

### "command not found: rails"
```bash
gem install rails
```

### "Webpacker::Manifest::MissingEntryError"
```bash
rails webpacker:install
rails webpacker:compile
```

### Porta 3000 já está em uso
```bash
# Use outra porta
rails server -p 3001
```

### Erro de permissão
```bash
# Dê permissão aos arquivos
chmod +x bin/*
```

---

## 🆘 Precisa de Ajuda?

1. **Erros de instalação:**
   - Certifique-se que Ruby e Rails estão instalados
   - Execute `bundle install` novamente

2. **Erros no banco de dados:**
   ```bash
   rails db:drop db:create db:migrate db:seed
   ```

3. **Servidor não inicia:**
   - Verifique se a porta 3000 está livre
   - Veja os logs de erro no terminal

4. **Páginas não aparecem:**
   - Limpe o cache do navegador
   - Tente em modo anônimo

---

## 🎓 Aprenda Mais

- **Rails Guides:** https://guides.rubyonrails.org/
- **Ruby Documentation:** https://ruby-doc.org/
- **Bootstrap Docs:** https://getbootstrap.com/
- **Devise:** https://github.com/heartcombo/devise

---

## 📝 Checklist de Instalação

- [ ] Ruby instalado (ruby -v)
- [ ] Rails instalado (rails -v)
- [ ] Arquivos baixados/extraídos
- [ ] bundle install executado
- [ ] rails db:create executado
- [ ] rails db:migrate executado
- [ ] rails db:seed executado (opcional)
- [ ] rails server executado
- [ ] Navegador aberto em localhost:3000
- [ ] Login funcionando

---

## 🎉 Pronto!

Se você chegou até aqui e conseguiu acessar o sistema no navegador, **parabéns!** 

Você agora tem um sistema completo de ordens de serviço rodando em sua máquina.

Explore, modifique e aprenda! 🚀

---

## 💡 Dica Final

Este é um projeto completo e profissional. Você pode:

1. **Usar como está** para gerenciar ordens de serviço
2. **Estudar o código** para aprender Rails
3. **Customizar** para suas necessidades
4. **Fazer deploy** para usar em produção
5. **Usar como base** para outros projetos

**O código está todo comentado e organizado para facilitar o entendimento!**

---

**Desenvolvido com Ruby on Rails 💎**
