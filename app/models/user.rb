class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :service_orders, dependent: :destroy
  has_one :technician, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  
  # Validação de senha forte
  validates :password, password_strength: true, if: :password_required?

  # Roles
  enum role: { user: 0, admin: 1 }

  after_initialize :set_default_role, if: :new_record?

  def set_default_role
    self.role ||= :user
  end
end
