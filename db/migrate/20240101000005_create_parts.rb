class CreateParts < ActiveRecord::Migration[7.1]
  def change
    create_table :parts do |t|
      t.string :name, null: false
      t.string :code
      t.text :description
      t.string :brand
      t.string :category
      t.decimal :unit_price, precision: 10, scale: 2, null: false, default: 0
      t.integer :stock_quantity, default: 0
      t.integer :minimum_stock, default: 0
      t.string :unit, default: "UN"
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :parts, :name
    add_index :parts, :code, unique: true
    add_index :parts, :category
    add_index :parts, :active
  end
end
