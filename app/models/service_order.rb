class ServiceOrder < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :status, presence: true
  validates :priority, presence: true
  validates :equipment_name, length: { maximum: 100 }, allow_blank: true
  validates :service_value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :parts_value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :total_value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Callbacks
  before_save :calculate_total_value

  # Enums for status and priority
  enum status: {
    pending: 0,
    in_progress: 1,
    completed: 2,
    cancelled: 3
  }

  enum priority: {
    low: 0,
    medium: 1,
    high: 2,
    urgent: 3
  }

  # Enum for payment status
  enum payment_status: {
    pending_payment: 0,
    paid: 1,
    partially_paid: 2,
    cancelled_payment: 3
  }, _prefix: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_priority, ->(priority) { where(priority: priority) }

  # Instance methods
  def can_be_completed?
    pending? || in_progress?
  end

  def can_be_cancelled?
    !cancelled? && !completed?
  end

  def mark_as_completed!
    update(status: :completed, completed_at: Time.current) if can_be_completed?
  end

  def mark_as_cancelled!
    update(status: :cancelled) if can_be_cancelled?
  end

  def overdue?
    due_date.present? && due_date < Date.current && !completed? && !cancelled?
  end

  def status_badge_class
    case status
    when "pending"
      "bg-warning"
    when "in_progress"
      "bg-info"
    when "completed"
      "bg-success"
    when "cancelled"
      "bg-secondary"
    end
  end

  def priority_badge_class
    case priority
    when "low"
      "bg-secondary"
    when "medium"
      "bg-primary"
    when "high"
      "bg-warning"
    when "urgent"
      "bg-danger"
    end
  end

  def equipment_info
    return "Sem equipamento cadastrado" if equipment_name.blank?
    
    info = [equipment_name]
    info << equipment_brand if equipment_brand.present?
    info << equipment_model if equipment_model.present?
    info.join(" - ")
  end

  def payment_status_badge_class
    case payment_status
    when "pending_payment"
      "bg-warning"
    when "paid"
      "bg-success"
    when "partially_paid"
      "bg-info"
    when "cancelled_payment"
      "bg-secondary"
    end
  end

  def formatted_service_value
    service_value.present? ? "R$ #{format('%.2f', service_value)}" : "R$ 0,00"
  end

  def formatted_parts_value
    parts_value.present? ? "R$ #{format('%.2f', parts_value)}" : "R$ 0,00"
  end

  def formatted_total_value
    total_value.present? ? "R$ #{format('%.2f', total_value)}" : "R$ 0,00"
  end

  private

  def calculate_total_value
    self.total_value = (service_value || 0) + (parts_value || 0)
  end
end
