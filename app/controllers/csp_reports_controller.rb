# frozen_string_literal: true

# Controller para receber relatórios de violação CSP
# Útil para monitorar tentativas de XSS e outras violações de segurança
class CspReportsController < ApplicationController
  # Desabilitar proteção CSRF para este endpoint
  # CSP reports são enviados pelo browser sem token CSRF
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  def create
    if Rails.env.production?
      # Em produção, registrar violações CSP
      Rails.logger.warn "CSP Violation: #{csp_report_params.to_json}"
      
      # Você pode também enviar para um serviço de monitoramento
      # como Sentry, Rollbar, etc.
      # Sentry.capture_message("CSP Violation", extra: csp_report_params)
    end

    head :ok
  end

  private

  def csp_report_params
    params.permit(
      'csp-report' => [
        'document-uri',
        'referrer',
        'violated-directive',
        'effective-directive',
        'original-policy',
        'blocked-uri',
        'status-code',
        'script-sample'
      ]
    )
  end
end
