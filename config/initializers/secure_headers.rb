# frozen_string_literal: true

# Configuração do SecureHeaders para proteção de segurança HTTP
# Documentação: https://github.com/github/secure_headers

SecureHeaders::Configuration.default do |config|
  
  # X-Frame-Options: Previne clickjacking
  # DENY: Página não pode ser exibida em iframe
  # SAMEORIGIN: Só pode ser exibida em iframe do mesmo domínio
  config.x_frame_options = "DENY"
  
  # X-Content-Type-Options: Previne MIME sniffing
  # nosniff: Força browser a respeitar o Content-Type declarado
  config.x_content_type_options = "nosniff"
  
  # X-XSS-Protection: Proteção XSS (legacy, mas ainda útil)
  # 1; mode=block: Ativa proteção e bloqueia página se detectar XSS
  config.x_xss_protection = "1; mode=block"
  
  # X-Download-Options: Previne execução automática de downloads (IE)
  config.x_download_options = "noopen"
  
  # X-Permitted-Cross-Domain-Policies: Controla Adobe Flash/PDF
  # none: Nenhuma política cross-domain permitida
  config.x_permitted_cross_domain_policies = "none"
  
  # Referrer-Policy: Controla informação de referrer enviada
  # origin-when-cross-origin: Envia URL completa para same-origin, só origin para cross-origin
  # strict-origin-when-cross-origin: Mais restritivo, não envia referrer em downgrade HTTPS→HTTP
  config.referrer_policy = %w[origin-when-cross-origin strict-origin-when-cross-origin]
  
  # Content-Security-Policy (CSP): Proteção robusta contra XSS
  # Controla quais recursos podem ser carregados
  config.csp = {
    # Configuração padrão
    default_src: %w['self'],
    
    # Scripts permitidos
    script_src: %w[
      'self'
      'unsafe-inline'
      https://cdn.jsdelivr.net
      https://cdn.tailwindcss.com
      https://cdnjs.cloudflare.com
    ],
    
    # Estilos permitidos
    style_src: %w[
      'self'
      'unsafe-inline'
      https://cdn.jsdelivr.net
      https://cdnjs.cloudflare.com
    ],
    
    # Fontes permitidas
    font_src: %w[
      'self'
      data:
      https://cdnjs.cloudflare.com
      https://cdn.jsdelivr.net
    ],
    
    # Imagens permitidas
    img_src: %w[
      'self'
      data:
      https:
      blob:
    ],
    
    # Objetos (Flash, Java, etc) - bloqueados
    object_src: %w['none'],
    
    # Conexões permitidas (AJAX, WebSocket)
    connect_src: %w[
      'self'
    ],
    
    # Frames permitidos (iframes)
    frame_src: %w['none'],
    
    # Workers permitidos
    worker_src: %w['self'],
    
    # Formulários podem enviar para
    form_action: %w['self'],
    
    # Onde recursos podem ser embebidos (frameancestors)
    frame_ancestors: %w['none'],
    
    # Base URI
    base_uri: %w['self'],
    
    # Manifest (PWA)
    manifest_src: %w['self'],
    
    # Mídia (audio/video)
    media_src: %w['self'],
    
    # Reportar violações CSP (opcional)
    # report_uri: %w[/csp_reports],
    
    # Aplicar CSP (true) ou só reportar (false)
    # Para testar, use false primeiro
    upgrade_insecure_requests: true # Força HTTPS
  }
  
  # Configuração menos restritiva para desenvolvimento
  # Descomente em development se tiver problemas
  # config.csp[:script_src] << "'unsafe-eval'" if Rails.env.development?
  
  # HSTS (HTTP Strict Transport Security)
  # Força HTTPS por um período de tempo
  # ATENÇÃO: Só ative em produção com HTTPS configurado!
  if Rails.env.production?
    config.hsts = "max-age=#{1.year.to_i}; includeSubDomains; preload"
  else
    # Em desenvolvimento, não forçar HTTPS
    config.hsts = SecureHeaders::OPT_OUT
  end
  
  # Clear-Site-Data: Limpar dados do site
  # Útil para logout seguro
  # config.clear_site_data = %w[cache cookies storage]
end

# Configuração override para páginas específicas
# Exemplo: Permitir iframe em páginas específicas
# SecureHeaders::Configuration.override(:allow_iframe) do |config|
#   config.x_frame_options = "SAMEORIGIN"
# end

# Para usar o override em um controller:
# class SomeController < ApplicationController
#   use_secure_headers_override(:allow_iframe)
# end

# Logging de violações CSP (desenvolvimento)
if Rails.env.development?
  # Para debug, você pode ver violações CSP no console
  Rails.application.config.action_dispatch.show_exceptions = true
end
