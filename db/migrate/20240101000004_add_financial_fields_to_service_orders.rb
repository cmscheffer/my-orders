class AddFinancialFieldsToServiceOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :service_orders, :service_value, :decimal, precision: 10, scale: 2
    add_column :service_orders, :parts_value, :decimal, precision: 10, scale: 2
    add_column :service_orders, :total_value, :decimal, precision: 10, scale: 2
    add_column :service_orders, :payment_status, :integer, default: 0
    add_column :service_orders, :payment_method, :string
    add_column :service_orders, :payment_date, :date
    add_column :service_orders, :notes, :text
    
    add_index :service_orders, :payment_status
    add_index :service_orders, :total_value
  end
end
