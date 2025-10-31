# 🔒 GUIA DE SEGURANÇA - Sistema de Ordens de Serviço

**Data:** 31 de Janeiro de 2025  
**Versão:** 1.2.0

---

## 🛡️ PROTEÇÕES IMPLEMENTADAS

### 1. **RACK ATTACK** - Proteção contra DDoS e Brute Force

#### **O que foi configurado:**

| Proteção | Limite | Período | O que previne |
|----------|--------|---------|---------------|
| **Login por Email** | 5 tentativas | 20 segundos | Brute force em senhas específicas |
| **Login por IP** | 10 tentativas | 1 minuto | Distributed brute force |
| **Requisições Gerais** | 300 requisições | 5 minutos | DDoS, scraping abusivo |
| **Criação de Ordens** | 10 criações | 1 minuto | Spam de ordens |
| **Geração de PDF** | 20 PDFs | 1 minuto | Sobrecarga do servidor |

#### **Arquivos criados:**
- ✅ `config/initializers/rack_attack.rb` - Configuração completa
- ✅ `public/429.html` - Página customizada de rate limit
- ✅ `config/application.rb` - Middleware habilitado

#### **Como funciona:**

1. **Throttling por Email:** Limita tentativas de login usando o mesmo email
2. **Throttling por IP:** Limita requisições totais do mesmo IP
3. **Safelist:** Localhost e assets não são limitados
4. **Response Customizado:** JSON com informações de retry
5. **Logging:** Registra todas as tentativas de throttling

#### **Resposta quando limite é atingido:**

```json
HTTP 429 Too Many Requests
{
  "error": "Muitas requisições. Tente novamente em alguns instantes.",
  "retry_after": 60
}
```

Headers retornados:
- `X-RateLimit-Limit`: Limite total
- `X-RateLimit-Remaining`: Requisições restantes
- `X-RateLimit-Reset`: Timestamp de reset

---

### 2. **SECURE HEADERS** - Proteção HTTP

#### **Headers configurados:**

| Header | Valor | Proteção |
|--------|-------|----------|
| **X-Frame-Options** | DENY | Previne clickjacking |
| **X-Content-Type-Options** | nosniff | Previne MIME sniffing |
| **X-XSS-Protection** | 1; mode=block | Proteção XSS (legacy) |
| **X-Download-Options** | noopen | Previne execução automática |
| **Referrer-Policy** | strict-origin-when-cross-origin | Controla vazamento de URLs |
| **HSTS** | max-age=31536000 | Força HTTPS (produção) |

#### **Content Security Policy (CSP):**

Controla quais recursos podem ser carregados:

```javascript
// Scripts permitidos
✅ 'self' (seu domínio)
✅ cdn.jsdelivr.net (jQuery, Bootstrap, Font Awesome)
✅ cdn.tailwindcss.com (Tailwind CSS)
✅ cdnjs.cloudflare.com (CDNs)

// Bloqueados
❌ Inline scripts não seguros
❌ eval() e Function()
❌ Iframes externos
❌ Flash, Java, plugins
```

#### **Arquivos criados:**
- ✅ `config/initializers/secure_headers.rb` - Configuração completa
- ✅ `app/controllers/csp_reports_controller.rb` - Recebe violações CSP
- ✅ `config/routes.rb` - Rota /csp_reports

---

## 🧪 COMO TESTAR

### **Teste 1: Rate Limiting de Login**

```bash
# No terminal (ou use curl):
for i in {1..6}; do
  curl -X POST http://localhost:3000/users/sign_in \
    -d "user[email]=test@example.com" \
    -d "user[password]=wrong"
  echo "Tentativa $i"
done

# Após 5 tentativas, você receberá:
# HTTP 429 - Muitas requisições
```

### **Teste 2: Rate Limiting Geral**

```bash
# Fazer 301 requisições em menos de 5 minutos:
for i in {1..301}; do
  curl -s http://localhost:3000/ > /dev/null
  echo "Requisição $i"
done

# Após 300 requisições, receberá HTTP 429
```

### **Teste 3: Verificar Headers de Segurança**

```bash
# No terminal:
curl -I http://localhost:3000/

# Você deve ver:
# X-Frame-Options: DENY
# X-Content-Type-Options: nosniff
# X-XSS-Protection: 1; mode=block
# Content-Security-Policy: default-src 'self'; ...
# Referrer-Policy: origin-when-cross-origin, strict-origin-when-cross-origin
```

### **Teste 4: Content Security Policy**

1. Abra o navegador em: http://localhost:3000
2. Abra DevTools (F12) → Console
3. Tente executar:
```javascript
eval('alert("XSS")')
```
4. Você verá erro CSP bloqueando a execução

### **Teste 5: Clickjacking Protection**

Tente embedar seu site em iframe:

```html
<iframe src="http://localhost:3000"></iframe>
```

O navegador bloqueará devido ao `X-Frame-Options: DENY`.

---

## 📊 MONITORAMENTO

### **Logs do Rack Attack:**

```bash
# Ver logs de throttling:
tail -f log/development.log | grep "Rack::Attack"

# Você verá:
# [Rack::Attack] Throttled 192.168.1.100 for /users/sign_in
# [Rack::Attack] Blocked 192.168.1.200 for /service_orders
```

### **Violações CSP:**

As violações CSP são logadas automaticamente:

```bash
tail -f log/production.log | grep "CSP Violation"

# Exemplo de violação:
# CSP Violation: {"document-uri":"http://example.com/","blocked-uri":"http://evil.com/script.js"}
```

### **Métricas Recomendadas:**

Em produção, monitore:
- Taxa de 429 responses (rate limiting)
- Violações CSP (tentativas de XSS)
- IPs bloqueados
- Tempo de resposta

---

## ⚙️ CONFIGURAÇÃO EM PRODUÇÃO

### **1. Habilitar HTTPS:**

O HSTS (Strict-Transport-Security) só deve ser ativado com HTTPS configurado:

```ruby
# config/initializers/secure_headers.rb
# Já está configurado para ativar apenas em production
if Rails.env.production?
  config.hsts = "max-age=#{1.year.to_i}; includeSubDomains; preload"
end
```

### **2. Usar Redis para Rack Attack:**

Em produção, use Redis ao invés de MemoryStore:

```ruby
# config/initializers/rack_attack.rb
# Descomente e configure:
Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
  url: ENV['REDIS_URL']
)
```

### **3. Ajustar Limites:**

Ajuste os limites de acordo com seu tráfego:

```ruby
# Para sites com alto tráfego legítimo:
throttle('req/ip', limit: 1000, period: 5.minutes) do |req|
  req.ip unless req.path.start_with?('/assets')
end
```

### **4. Blocklist de IPs:**

Bloqueie IPs maliciosos conhecidos:

```ruby
# config/initializers/rack_attack.rb
blocklist('block bad IPs') do |req|
  ['123.45.67.89', '98.76.54.32'].include?(req.ip)
end
```

---

## 🚨 RESPOSTA A INCIDENTES

### **Se detectar ataque:**

1. **Identificar o IP:**
```bash
tail -f log/production.log | grep "Rack::Attack"
```

2. **Bloquear temporariamente:**
```ruby
# No Rails console:
Rack::Attack::Allow2Ban.filter("ip:#{ip}", maxretry: 0, findtime: 1.day, bantime: 1.day) do
  true
end
```

3. **Adicionar à blocklist permanente:**
```ruby
# config/initializers/rack_attack.rb
blocklist('block bad IPs') do |req|
  ['IP_MALICIOSO'].include?(req.ip)
end
```

4. **Reiniciar aplicação:**
```bash
sudo systemctl restart your-app
```

---

## ✅ CHECKLIST DE SEGURANÇA

### **Antes de ir para produção:**

- [ ] HTTPS configurado e funcionando
- [ ] Redis configurado para Rack Attack
- [ ] HSTS habilitado
- [ ] Logs de segurança configurados
- [ ] Monitoramento de violações CSP
- [ ] Backup de logs de segurança
- [ ] Teste de penetração realizado
- [ ] Rate limits ajustados para tráfego esperado
- [ ] Blocklist de IPs conhecidos populada
- [ ] Alertas configurados para 429 responses

---

## 📚 RECURSOS ADICIONAIS

### **Documentação:**
- [Rack Attack GitHub](https://github.com/rack/rack-attack)
- [Secure Headers GitHub](https://github.com/github/secure_headers)
- [OWASP Security Headers](https://owasp.org/www-project-secure-headers/)
- [CSP Reference](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)

### **Ferramentas de Teste:**
- [SecurityHeaders.com](https://securityheaders.com) - Teste seus headers
- [CSP Evaluator](https://csp-evaluator.withgoogle.com) - Valide seu CSP
- [SSL Labs](https://www.ssllabs.com/ssltest/) - Teste seu HTTPS

---

## 🎯 NÍVEIS DE SEGURANÇA

### **🟢 Atual (Implementado):**
- ✅ Rate limiting (Rack Attack)
- ✅ Security headers (Secure Headers)
- ✅ CSP básico
- ✅ Proteção contra clickjacking
- ✅ Proteção XSS

### **🟡 Recomendado (Próximos Passos):**
- ⏳ Autenticação de 2 fatores (2FA)
- ⏳ Captcha em login
- ⏳ IP whitelisting para admin
- ⏳ Auditoria de ações (PaperTrail)
- ⏳ Criptografia de dados sensíveis

### **🔴 Avançado (Opcional):**
- ⏳ WAF (Web Application Firewall)
- ⏳ IDS/IPS
- ⏳ Penetration testing regular
- ⏳ Bug bounty program
- ⏳ SOC 2 compliance

---

## 📞 CONTATO DE SEGURANÇA

Para reportar vulnerabilidades de segurança:
- **Email:** security@your-company.com (configure)
- **Bug Bounty:** (se aplicável)

**Não divulgue vulnerabilidades publicamente antes de reportar!**

---

**Última atualização:** 31/01/2025  
**Próxima revisão:** 31/03/2025
