class CompanySetting < ApplicationRecord
  validates :logo_filename, presence: true, if: :logo_data?
  validate :validate_logo_size, if: :logo_data?
  validate :validate_logo_format, if: :logo_filename?

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

  private

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
end
