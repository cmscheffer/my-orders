class AddTechnicianToServiceOrders < ActiveRecord::Migration[7.1]
  def change
    add_reference :service_orders, :technician, foreign_key: true
    add_index :service_orders, :technician_id
  end
end
