class Part < ApplicationRecord
  has_many :service_order_parts, dependent: :destroy
  has_many :service_orders, through: :service_order_parts

  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :code, uniqueness: true, allow_blank: true
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :minimum_stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :low_stock, -> { where("stock_quantity <= minimum_stock") }
  scope :search, ->(query) { where("name LIKE ? OR code LIKE ? OR description LIKE ?", "%#{query}%", "%#{query}%", "%#{query}%") }

  # Callbacks
  before_save :generate_code, if: -> { code.blank? }

  def formatted_unit_price
    "R$ #{format('%.2f', unit_price)}"
  end

  def stock_status
    if stock_quantity <= 0
      "Sem estoque"
    elsif stock_quantity <= minimum_stock
      "Estoque baixo"
    else
      "Em estoque"
    end
  end

  def stock_badge_class
    if stock_quantity <= 0
      "bg-danger"
    elsif stock_quantity <= minimum_stock
      "bg-warning"
    else
      "bg-success"
    end
  end

  def full_name
    code.present? ? "#{code} - #{name}" : name
  end

  private

  def generate_code
    self.code = "P#{Time.current.strftime('%Y%m%d')}#{rand(1000..9999)}"
  end
end
