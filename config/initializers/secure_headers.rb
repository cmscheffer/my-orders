# frozen_string_literal: true

# Configuração de headers de segurança HTTP
# Gem: secure_headers
# Documentação: https://github.com/github/secure_headers

SecureHeaders::Configuration.default do |config|
  # Define a política de segurança de conteúdo (CSP)
  # Permite apenas recursos do mesmo domínio e CDNs confiáveis
  config.csp = {
    default_src: %w['self'],
    font_src: %w['self' data: https://cdnjs.cloudflare.com https://fonts.gstatic.com],
    img_src: %w['self' data: https:],
    object_src: %w['none'],
    script_src: %w['self' 'unsafe-inline' https://cdnjs.cloudflare.com https://cdn.jsdelivr.net],
    style_src: %w['self' 'unsafe-inline' https://cdnjs.cloudflare.com https://fonts.googleapis.com],
    connect_src: %w['self'],
    base_uri: %w['self'],
    form_action: %w['self'],
    frame_ancestors: %w['none'],
    upgrade_insecure_requests: true # Força upgrade de HTTP para HTTPS
  }

  # Strict-Transport-Security (HSTS)
  # Força HTTPS por 1 ano, incluindo subdomínios
  config.hsts = "max-age=#{1.year.to_i}; includeSubDomains; preload"

  # X-Frame-Options: Previne clickjacking
  # DENY = não permite que o site seja exibido em frames/iframes
  config.x_frame_options = "DENY"

  # X-Content-Type-Options: Previne MIME type sniffing
  # nosniff = navegador deve respeitar o Content-Type declarado
  config.x_content_type_options = "nosniff"

  # X-XSS-Protection: Proteção contra XSS (cross-site scripting)
  # mode=block = bloqueia a página se detectar XSS
  config.x_xss_protection = "1; mode=block"

  # Referrer-Policy: Controla informações de referência enviadas
  # strict-origin-when-cross-origin = envia origem completa apenas para mesmo domínio
  config.referrer_policy = %w[strict-origin-when-cross-origin]

  # X-Permitted-Cross-Domain-Policies: Controla acesso de Flash/PDF
  # none = não permite nenhum domínio cruzado
  config.x_permitted_cross_domain_policies = "none"

  # X-Download-Options: Previne downloads automáticos no IE
  config.x_download_options = "noopen"
end

# Configuração específica para Rails 7.1
# Habilita proteção CSRF (Cross-Site Request Forgery) com origin check
Rails.application.config.action_controller.default_protect_from_forgery = true
Rails.application.config.action_controller.forgery_protection_origin_check = true
