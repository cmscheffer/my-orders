class AddEquipmentToServiceOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :service_orders, :equipment_name, :string
    add_column :service_orders, :equipment_model, :string
    add_column :service_orders, :equipment_serial, :string
    add_column :service_orders, :equipment_brand, :string
    
    add_index :service_orders, :equipment_serial
  end
end
