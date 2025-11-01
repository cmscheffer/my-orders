# frozen_string_literal: true

module PasswordHelper
  # Retorna HTML com os requisitos de senha
  def password_requirements_list
    content_tag(:div, class: 'password-requirements alert alert-info') do
      content_tag(:h6, class: 'alert-heading') do
        content_tag(:i, '', class: 'fas fa-info-circle') + ' Requisitos de Senha'
      end +
      content_tag(:ul, class: 'mb-0') do
        PasswordStrengthValidator.requirements.map do |requirement|
          content_tag(:li, requirement)
        end.join.html_safe
      end
    end
  end
  
  # Retorna HTML com indicador de força de senha
  def password_strength_indicator
    content_tag(:div, class: 'password-strength-indicator mt-2', style: 'display: none;') do
      content_tag(:small, class: 'text-muted') do
        'Força da senha: '
      end +
      content_tag(:span, '', class: 'password-strength-text fw-bold') +
      content_tag(:div, class: 'progress mt-1', style: 'height: 5px;') do
        content_tag(:div, '', 
          class: 'progress-bar password-strength-bar', 
          role: 'progressbar',
          style: 'width: 0%',
          'aria-valuenow': '0',
          'aria-valuemin': '0',
          'aria-valuemax': '100')
      end
    end
  end
end
