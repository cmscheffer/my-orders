class CompanySetting < ApplicationRecord
  validates :logo_filename, presence: true, if: :logo_data?
  validate :validate_logo_size, if: :logo_data?
  validate :validate_logo_format, if: :logo_filename?
  validate :validate_cnpj, if: :cnpj?

  # Normaliza CNPJ antes de salvar (remove pontuação)
  before_save :normalize_cnpj, if: :cnpj?

  # Retorna a instância singleton das configurações
  def self.instance
    first_or_create
  end

  # Verifica se tem logo
  def has_logo?
    logo_data.present? && logo_filename.present?
  end

  # Retorna o logo em base64 para usar em HTML/PDF
  def logo_base64
    return nil unless has_logo?
    Base64.strict_encode64(logo_data)
  end

  # Retorna o tipo MIME baseado na extensão
  def logo_mime_type
    return nil unless logo_filename.present?
    
    ext = File.extname(logo_filename).downcase
    case ext
    when '.png' then 'image/png'
    when '.jpg', '.jpeg' then 'image/jpeg'
    when '.gif' then 'image/gif'
    when '.svg' then 'image/svg+xml'
    else 'application/octet-stream'
    end
  end

  # Retorna data URI completa para uso em src de imagem
  def logo_data_uri
    return nil unless has_logo?
    "data:#{logo_mime_type};base64,#{logo_base64}"
  end

  # Remove o logo
  def remove_logo!
    self.logo_data = nil
    self.logo_filename = nil
    save
  end

  # Retorna CNPJ formatado para exibição
  def formatted_cnpj
    return nil unless cnpj.present?
    
    # Remove tudo que não for número
    numbers = cnpj.gsub(/\D/, '')
    
    # Formata: XX.XXX.XXX/XXXX-XX
    return cnpj unless numbers.length == 14
    
    "#{numbers[0..1]}.#{numbers[2..4]}.#{numbers[5..7]}/#{numbers[8..11]}-#{numbers[12..13]}"
  end

  private

  def normalize_cnpj
    # Remove todos os caracteres não numéricos
    self.cnpj = cnpj.gsub(/\D/, '') if cnpj.present?
  end

  def validate_logo_size
    max_size = 2.megabytes
    if logo_data && logo_data.bytesize > max_size
      errors.add(:logo_data, "deve ter no máximo 2MB")
    end
  end

  def validate_logo_format
    allowed_extensions = %w[.png .jpg .jpeg .gif .svg]
    ext = File.extname(logo_filename).downcase
    
    unless allowed_extensions.include?(ext)
      errors.add(:logo_filename, "deve ser PNG, JPG, GIF ou SVG")
    end
  end

  def validate_cnpj
    # Remove caracteres não numéricos
    numbers = cnpj.gsub(/\D/, '')
    
    # Verifica se tem 14 dígitos
    unless numbers.length == 14
      errors.add(:cnpj, "deve conter 14 dígitos")
      return
    end
    
    # Verifica se não são todos iguais (ex: 00000000000000)
    if numbers.chars.uniq.length == 1
      errors.add(:cnpj, "é inválido")
      return
    end
    
    # Validação do primeiro dígito verificador
    sum = 0
    weights = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
    
    12.times do |i|
      sum += numbers[i].to_i * weights[i]
    end
    
    remainder = sum % 11
    first_digit = remainder < 2 ? 0 : 11 - remainder
    
    unless first_digit == numbers[12].to_i
      errors.add(:cnpj, "é inválido")
      return
    end
    
    # Validação do segundo dígito verificador
    sum = 0
    weights = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
    
    13.times do |i|
      sum += numbers[i].to_i * weights[i]
    end
    
    remainder = sum % 11
    second_digit = remainder < 2 ? 0 : 11 - remainder
    
    unless second_digit == numbers[13].to_i
      errors.add(:cnpj, "é inválido")
    end
  end
end
