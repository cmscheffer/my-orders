class Technician < ApplicationRecord
  belongs_to :user, optional: true
  has_many :service_orders, dependent: :nullify

  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true, uniqueness: true
  validates :phone, length: { minimum: 10, maximum: 15 }, allow_blank: true

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_specialty, ->(specialty) { where(specialty: specialty) if specialty.present? }

  # Especialidades disponíveis
  SPECIALTIES = [
    'Hardware',
    'Software',
    'Redes',
    'Eletrônica',
    'Impressoras',
    'Notebooks',
    'Desktops',
    'Smartphones',
    'Manutenção Preventiva',
    'Recuperação de Dados',
    'Instalação',
    'Suporte Técnico',
    'Outro'
  ].freeze

  def full_info
    info = name
    info += " - #{specialty}" if specialty.present?
    info
  end

  def status_text
    active? ? 'Ativo' : 'Inativo'
  end

  def status_badge_class
    active? ? 'bg-success' : 'bg-secondary'
  end

  def orders_count
    service_orders.count
  end

  def orders_in_progress_count
    service_orders.where(status: [:pending, :in_progress, :waiting_parts]).count
  end

  def formatted_phone
    return phone unless phone.present?
    
    # Format: (XX) XXXXX-XXXX or (XX) XXXX-XXXX
    phone_digits = phone.gsub(/\D/, '')
    
    if phone_digits.length == 11
      "(#{phone_digits[0..1]}) #{phone_digits[2..6]}-#{phone_digits[7..10]}"
    elsif phone_digits.length == 10
      "(#{phone_digits[0..1]}) #{phone_digits[2..5]}-#{phone_digits[6..9]}"
    else
      phone
    end
  end
end
