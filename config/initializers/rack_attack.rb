# frozen_string_literal: true

# Configuração do Rack Attack para proteção contra DDoS e ataques de força bruta
# Gem: rack-attack
# Documentação: https://github.com/rack/rack-attack

class Rack::Attack
  ### Configurar cache store ###
  # Por padrão usa Rails.cache, mas pode ser configurado separadamente
  # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  ### Throttle (Limitação de taxa) ###

  # 1. Proteção geral contra requisições excessivas
  # Limita a 300 requisições por minuto por IP
  throttle('req/ip', limit: 300, period: 1.minute) do |req|
    req.ip unless req.path.start_with?('/assets') # Não aplica para assets estáticos
  end

  # 2. Proteção específica para login (força bruta)
  # Limita a 5 tentativas de login por IP a cada 20 segundos
  throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
    if req.path == '/users/sign_in' && req.post?
      req.ip
    end
  end

  # 3. Proteção para login por email
  # Limita a 5 tentativas por email a cada 20 segundos
  throttle('logins/email', limit: 5, period: 20.seconds) do |req|
    if req.path == '/users/sign_in' && req.post?
      # Normalizar email para lowercase
      req.params['user']['email'].to_s.downcase.presence
    end
  end

  # 4. Proteção para criação de conta
  # Limita a 3 registros por IP por hora
  throttle('registrations/ip', limit: 3, period: 1.hour) do |req|
    if req.path == '/users' && req.post?
      req.ip
    end
  end

  # 5. Proteção para API (se houver no futuro)
  # Limita a 100 requisições por minuto para endpoints de API
  throttle('api/ip', limit: 100, period: 1.minute) do |req|
    if req.path.start_with?('/api')
      req.ip
    end
  end

  ### Blocklists (Listas negras) ###

  # Bloquear IPs específicos (adicionar IPs maliciosos conhecidos)
  # blocklist('block bad IPs') do |req|
  #   # Exemplo: ['1.2.3.4', '5.6.7.8'].include?(req.ip)
  #   false # Desabilitado por padrão
  # end

  # Bloquear User-Agents suspeitos
  blocklist('block suspicious user agents') do |req|
    # Bloqueia requisições sem User-Agent ou com User-Agents de bots maliciosos
    user_agent = req.user_agent.to_s.downcase
    
    # Lista de User-Agents suspeitos
    suspicious_agents = [
      'masscan',
      'nmap',
      'nikto',
      'sqlmap',
      'python-requests', # Ajustar conforme necessário
      'scrapy',
      'curl' # Remover se você usar curl para monitoramento
    ]
    
    # Bloqueia se não tiver User-Agent ou se for suspeito
    user_agent.blank? || suspicious_agents.any? { |agent| user_agent.include?(agent) }
  end

  ### Safelists (Listas brancas) ###

  # Permitir IPs confiáveis (localhost, IPs internos, monitoramento)
  safelist('allow from localhost') do |req|
    # Permitir localhost
    ['127.0.0.1', '::1'].include?(req.ip) ||
    # Permitir IPs privados (ajustar conforme necessário)
    req.ip.start_with?('192.168.') ||
    req.ip.start_with?('10.') ||
    req.ip.start_with?('172.')
  end

  # Permitir health checks
  safelist('allow health checks') do |req|
    req.path == '/up' || req.path == '/health'
  end

  ### Customizar resposta para requisições bloqueadas ###

  # Resposta quando o limite é atingido
  self.throttled_responder = lambda do |request|
    match_data = request.env['rack.attack.match_data']
    now = match_data[:epoch_time]
    
    # Calcular quando o limite será resetado
    headers = {
      'RateLimit-Limit' => match_data[:limit].to_s,
      'RateLimit-Remaining' => '0',
      'RateLimit-Reset' => (now + (match_data[:period] - (now % match_data[:period]))).to_s,
      'Content-Type' => 'text/html'
    }
    
    # Mensagem em português
    body = <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <title>Muitas Requisições</title>
        <style>
          body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
          h1 { color: #dc3545; }
        </style>
      </head>
      <body>
        <h1>⚠️ Muitas Requisições</h1>
        <p>Você excedeu o limite de requisições permitidas.</p>
        <p>Por favor, aguarde alguns instantes e tente novamente.</p>
      </body>
      </html>
    HTML
    
    [429, headers, [body]]
  end

  # Resposta quando o IP está bloqueado
  self.blocklisted_responder = lambda do |request|
    [403, {'Content-Type' => 'text/html'}, [<<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <title>Acesso Bloqueado</title>
        <style>
          body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
          h1 { color: #dc3545; }
        </style>
      </head>
      <body>
        <h1>🚫 Acesso Bloqueado</h1>
        <p>Seu acesso foi bloqueado devido a atividade suspeita.</p>
        <p>Se você acredita que isso é um erro, entre em contato com o suporte.</p>
      </body>
      </html>
    HTML
    ]]
  end

  ### Logging e notificações ###

  # Log de requisições bloqueadas (apenas em produção)
  ActiveSupport::Notifications.subscribe('rack.attack') do |name, start, finish, request_id, payload|
    req = payload[:request]
    
    if req.env['rack.attack.matched']
      Rails.logger.warn "[Rack::Attack] #{req.env['rack.attack.match_type']}: " \
                        "#{req.ip} #{req.request_method} #{req.fullpath} " \
                        "matched #{req.env['rack.attack.matched']}"
    end
  end
end

# Habilitar Rack Attack apenas em produção
Rails.application.config.middleware.use Rack::Attack if Rails.env.production?
