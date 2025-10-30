class CreateServiceOrderParts < ActiveRecord::Migration[7.1]
  def change
    create_table :service_order_parts do |t|
      t.references :service_order, null: false, foreign_key: true
      t.references :part, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.decimal :total_price, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :service_order_parts, [:service_order_id, :part_id], unique: true
  end
end
