class AddTechnicianToServiceOrders < ActiveRecord::Migration[7.1]
  def change
    add_reference :service_orders, :technician, foreign_key: true, index: true
  end
end
