class ServiceOrder < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :status, presence: true
  validates :priority, presence: true

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
end
