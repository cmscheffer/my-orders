# frozen_string_literal: true

# Validador customizado para força de senha
# Requisitos:
# - Mínimo 6 caracteres
# - Pelo menos 1 letra maiúscula
# - Pelo menos 1 número
# - Pelo menos 1 caractere especial
class PasswordStrengthValidator < ActiveModel::EachValidator
  MINIMUM_LENGTH = 6
  
  # Caracteres especiais permitidos
  SPECIAL_CHARACTERS = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/
  
  def validate_each(record, attribute, value)
    return if value.blank? # Deixa o Devise validar presença
    
    errors = []
    
    # Validar comprimento mínimo
    if value.length < MINIMUM_LENGTH
      errors << "deve ter no mínimo #{MINIMUM_LENGTH} caracteres"
    end
    
    # Validar letra maiúscula
    unless value.match?(/[A-Z]/)
      errors << "deve conter pelo menos uma letra maiúscula"
    end
    
    # Validar número
    unless value.match?(/[0-9]/)
      errors << "deve conter pelo menos um número"
    end
    
    # Validar caractere especial
    unless value.match?(SPECIAL_CHARACTERS)
      errors << "deve conter pelo menos um caractere especial (!@#$%^&* etc)"
    end
    
    # Adicionar todos os erros
    errors.each do |error|
      record.errors.add(attribute, error)
    end
  end
  
  # Método auxiliar para verificar se a senha é forte
  def self.strong_password?(password)
    return false if password.blank?
    return false if password.length < MINIMUM_LENGTH
    return false unless password.match?(/[A-Z]/)
    return false unless password.match?(/[0-9]/)
    return false unless password.match?(SPECIAL_CHARACTERS)
    
    true
  end
  
  # Método para obter requisitos de senha
  def self.requirements
    [
      "Mínimo #{MINIMUM_LENGTH} caracteres",
      "Pelo menos 1 letra maiúscula (A-Z)",
      "Pelo menos 1 número (0-9)",
      "Pelo menos 1 caractere especial (!@#$%^&* etc)"
    ]
  end
end
