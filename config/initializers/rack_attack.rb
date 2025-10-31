# frozen_string_literal: true

# Configuração do Rack Attack para proteção contra DDoS e brute force
# Documentação: https://github.com/rack/rack-attack

class Rack::Attack
  
  ### Configure Cache ###
  
  # Se você tiver Redis em produção, use:
  # Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new
  
  # Para desenvolvimento/teste, use memory store:
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  
  ### Throttle Configuration ###
  
  # 1. Limitar tentativas de login por email
  # Previne ataques de brute force em senhas
  throttle('logins/email', limit: 5, period: 20.seconds) do |req|
    if req.path == '/users/sign_in' && req.post?
      # Retorna o email como chave de throttling
      # normaliza: downcase e remove espaços
      req.params['user']&.dig('email')&.to_s&.downcase&.gsub(/\s+/, "")
    end
  end
  
  # 2. Limitar tentativas de login por IP
  # Previne distributed brute force attacks
  throttle('logins/ip', limit: 10, period: 1.minute) do |req|
    if req.path == '/users/sign_in' && req.post?
      req.ip
    end
  end
  
  # 3. Limitar requisições gerais por IP
  # Previne DDoS e scraping abusivo
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?('/assets')
  end
  
  # 4. Limitar criação de ordens de serviço por IP
  # Previne spam de ordens
  throttle('service_orders/ip', limit: 10, period: 1.minute) do |req|
    if req.path == '/service_orders' && req.post?
      req.ip
    end
  end
  
  # 5. Limitar requisições de PDF por IP
  # PDFs são pesados, limitar para evitar sobrecarga
  throttle('pdf/ip', limit: 20, period: 1.minute) do |req|
    if req.path.include?('/pdf')
      req.ip
    end
  end
  
  ### Blocklist & Safelist ###
  
  # Bloquear IPs específicos (adicione IPs maliciosos aqui)
  # blocklist('block bad IPs') do |req|
  #   # Retorna true para bloquear
  #   ['123.456.789.0', '111.222.333.444'].include?(req.ip)
  # end
  
  # Safelist: Não aplicar throttling para IPs confiáveis
  safelist('allow from localhost') do |req|
    # Permite requisições do localhost sem limite
    ['127.0.0.1', '::1', 'localhost'].include?(req.ip)
  end
  
  # Safelist: Não limitar assets
  safelist('allow assets') do |req|
    req.path.start_with?('/assets', '/favicon.ico')
  end
  
  ### Response Customization ###
  
  # Resposta customizada quando rate limit é atingido
  self.throttled_responder = lambda do |env|
    match_data = env['rack.attack.match_data']
    now = match_data[:epoch_time]
    
    headers = {
      'Content-Type' => 'application/json',
      'X-RateLimit-Limit' => match_data[:limit].to_s,
      'X-RateLimit-Remaining' => '0',
      'X-RateLimit-Reset' => (now + (match_data[:period] - now % match_data[:period])).to_s
    }
    
    body = {
      error: 'Muitas requisições. Tente novamente em alguns instantes.',
      retry_after: match_data[:period]
    }.to_json
    
    [429, headers, [body]]
  end
  
  ### Logging ###
  
  # Log de throttling
  ActiveSupport::Notifications.subscribe('throttle.rack_attack') do |name, start, finish, request_id, payload|
    req = payload[:request]
    Rails.logger.warn "[Rack::Attack] Throttled #{req.ip} for #{req.path}"
  end
  
  # Log de blocklist
  ActiveSupport::Notifications.subscribe('blocklist.rack_attack') do |name, start, finish, request_id, payload|
    req = payload[:request]
    Rails.logger.warn "[Rack::Attack] Blocked #{req.ip} for #{req.path}"
  end
  
  # Log de safelist (opcional, pode ser verbose)
  # ActiveSupport::Notifications.subscribe('safelist.rack_attack') do |name, start, finish, request_id, payload|
  #   req = payload[:request]
  #   Rails.logger.info "[Rack::Attack] Safelisted #{req.ip} for #{req.path}"
  # end
end
