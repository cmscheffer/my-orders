class CreateServiceOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :service_orders do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.integer :status, default: 0, null: false
      t.integer :priority, default: 1, null: false
      t.date :due_date
      t.datetime :completed_at
      t.string :customer_name
      t.string :customer_email
      t.string :customer_phone
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :service_orders, :status
    add_index :service_orders, :priority
    add_index :service_orders, :due_date
    add_index :service_orders, :created_at
  end
end
