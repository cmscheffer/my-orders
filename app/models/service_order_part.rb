class ServiceOrderPart < ApplicationRecord
  belongs_to :service_order
  belongs_to :part

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :part_id, uniqueness: { scope: :service_order_id, message: "já foi adicionada a esta ordem" }

  # Callbacks
  before_save :calculate_total_price
  after_save :update_service_order_parts_value
  after_destroy :update_service_order_parts_value

  def formatted_unit_price
    "R$ #{format('%.2f', unit_price)}"
  end

  def formatted_total_price
    "R$ #{format('%.2f', total_price)}"
  end

  private

  def calculate_total_price
    self.total_price = (quantity || 0) * (unit_price || 0)
  end

  def update_service_order_parts_value
    return unless service_order

    total = service_order.service_order_parts.sum(:total_price)
    service_order.update_column(:parts_value, total)
  end
end
