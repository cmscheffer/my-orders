# frozen_string_literal: true

class Customer < ApplicationRecord
  # Associations
  has_many :service_orders, dependent: :nullify, foreign_key: :customer_name, primary_key: :name
  
  # Validations
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone, presence: true
  
  # Callbacks
  before_save :normalize_data
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :alphabetical, -> { order(:name) }
  
  # Instance methods
  def full_info
    info = [name]
    info << email if email.present?
    info << phone if phone.present?
    info.join(" | ")
  end
  
  def total_orders
    ServiceOrder.where(customer_name: name).count
  end
  
  def total_spent
    ServiceOrder.where(customer_name: name).completed.sum(:total_value)
  end
  
  def last_order
    ServiceOrder.where(customer_name: name).order(created_at: :desc).first
  end
  
  def toggle_active!
    update(active: !active)
  end
  
  private
  
  def normalize_data
    self.name = name.strip.titleize if name.present?
    self.email = email.strip.downcase if email.present?
    self.phone = phone.strip if phone.present?
  end
end
