# 🔑 ATUALIZAR CREDENTIALS - INSTRUÇÕES

## ✅ Passo 1: Nova MASTER_KEY já foi atualizada!

O arquivo `config/master.key` foi atualizado com a nova chave:
```
4553438c5aff6dc01e8725090d1edccf86b8439fc7aff6923637bbbac7ba9ed6
```

## 🔐 Passo 2: Atualizar credentials.yml.enc

### **Na sua máquina local, execute:**

```bash
# 1. Navegue até o projeto
cd /caminho/para/my-orders

# 2. Puxe as alterações do Git (contém a nova master.key)
git pull origin main

# 3. Remova o credentials.yml.enc antigo (se existir)
rm -f config/credentials.yml.enc

# 4. Abra o editor de credentials (isso cria um novo arquivo criptografado)
EDITOR="nano" rails credentials:edit
```

### **No editor que abrir, cole este conteúdo:**

```yaml
# Secret Key Base para produção
secret_key_base: 0abc53e7ac31c4139d81ebeef8ba5d63b1f6a5e6c155c38b8367c6d033b71c1c560bd2d780a75c9d6ac06585b3173add1d53639a6d4f02779a5a17fb8685e5bb

# Adicione aqui outras credenciais conforme necessário:
# 
# aws:
#   access_key_id: AKIAIOSFODNN7EXAMPLE
#   secret_access_key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
#
# sendgrid:
#   api_key: SG.XXXXXXXXXXXXXXXXX
#
# stripe:
#   publishable_key: pk_live_XXXXXXXX
#   secret_key: sk_live_XXXXXXXX
```

### **Salve e feche o editor:**
- No nano: `Ctrl+X`, depois `Y`, depois `Enter`
- Isso criará automaticamente o arquivo `config/credentials.yml.enc` criptografado

## 📝 Passo 3: Commit das alterações

```bash
# Commitar o novo credentials.yml.enc (o master.key NÃO será commitado)
git add config/credentials.yml.enc
git commit -m "security: Atualiza credentials com novas chaves de segurança"
git push origin main
```

---

## 🚀 Configuração para PRODUÇÃO (Servidor Vultr)

### **Arquivo .env.production no servidor:**

```bash
# ==========================================
# VARIÁVEIS DE AMBIENTE - PRODUÇÃO
# ==========================================

# === SEGURANÇA ===
# Nova Secret Key Base
SECRET_KEY_BASE=0abc53e7ac31c4139d81ebeef8ba5d63b1f6a5e6c155c38b8367c6d033b71c1c560bd2d780a75c9d6ac06585b3173add1d53639a6d4f02779a5a17fb8685e5bb

# Nova Master Key
RAILS_MASTER_KEY=4553438c5aff6dc01e8725090d1edccf86b8439fc7aff6923637bbbac7ba9ed6

# === BANCO DE DADOS ===
# AJUSTE: Troque pela senha real do PostgreSQL
DATABASE_URL=postgresql://deploy:SenhaSuperSegura@123@localhost/service_orders_production

# === RAILS ===
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true

# === DEVISE (Email) ===
# AJUSTE: Troque pelo seu domínio real
DEVISE_MAILER_HOST=seu-dominio.com

# === EMAILS (Opcional - se for configurar SMTP) ===
# SMTP_ADDRESS=smtp.gmail.com
# SMTP_PORT=587
# SMTP_USERNAME=seu-email@gmail.com
# SMTP_PASSWORD=sua-senha-app
# SMTP_DOMAIN=seu-dominio.com
```

### **Como usar no servidor:**

```bash
# No servidor Vultr, como usuário deploy:
cd /home/deploy/my-orders
nano .env.production

# Cole o conteúdo acima (ajuste DATABASE_URL e DEVISE_MAILER_HOST)

# Proteja o arquivo:
chmod 600 .env.production

# Reinicie o serviço:
sudo systemctl restart my-orders
```

---

## ⚠️ IMPORTANTE: Backup das Chaves

### **Guarde estas informações em local SEGURO:**

**SECRET_KEY_BASE:**
```
0abc53e7ac31c4139d81ebeef8ba5d63b1f6a5e6c155c38b8367c6d033b71c1c560bd2d780a75c9d6ac06585b3173add1d53639a6d4f02779a5a17fb8685e5bb
```

**RAILS_MASTER_KEY:**
```
4553438c5aff6dc01e8725090d1edccf86b8439fc7aff6923637bbbac7ba9ed6
```

### **Onde guardar:**
- ✅ Gerenciador de senhas (LastPass, 1Password, Bitwarden)
- ✅ Cofre criptografado
- ✅ Arquivo criptografado local
- ❌ NUNCA em email, chat público, ou documentação pública

---

## 🧪 Testar localmente (Desenvolvimento)

```bash
# Teste se as credentials foram criadas corretamente:
EDITOR="cat" rails credentials:show

# Deve mostrar o conteúdo descriptografado, incluindo:
# secret_key_base: 0abc53e7ac...

# Teste a aplicação localmente:
rails server

# Acesse: http://localhost:3000
```

---

## 📋 Checklist Final

- [ ] Master.key atualizado localmente (git pull)
- [ ] Credentials.yml.enc recriado (rails credentials:edit)
- [ ] Secret_key_base no credentials
- [ ] Commit e push do novo credentials.yml.enc
- [ ] .env.production criado no servidor Vultr
- [ ] Permissões corretas (chmod 600 .env.production)
- [ ] Serviço reiniciado no servidor
- [ ] Backup das chaves em local seguro
- [ ] Teste de acesso à aplicação em produção

---

## 🆘 Troubleshooting

### **Erro: "ActiveSupport::MessageEncryptor::InvalidMessage"**
- **Causa:** Master key incorreta ou credentials corrompidos
- **Solução:** Verifique se a RAILS_MASTER_KEY está correta no .env.production

### **Erro: "Couldn't decrypt config/credentials.yml.enc"**
- **Causa:** Master key não corresponde ao arquivo criptografado
- **Solução:** Recrie o credentials.yml.enc conforme Passo 2

### **Sessões de usuários inválidas após deploy**
- **Causa:** SECRET_KEY_BASE mudou
- **Esperado:** Todos os usuários serão deslogados automaticamente
- **Ação:** Normal, usuários precisam fazer login novamente

---

## 📞 Dúvidas?

Se tiver problemas, verifique:
1. RAILS_MASTER_KEY no .env.production está correta
2. SECRET_KEY_BASE está definida no .env.production OU no credentials
3. Arquivo .env.production tem permissão 600
4. Systemd está carregando o .env.production (EnvironmentFile)

**Logs para debug:**
```bash
# Ver logs da aplicação:
tail -f /home/deploy/my-orders/log/production.log

# Ver logs do systemd:
sudo journalctl -u my-orders -f
```
