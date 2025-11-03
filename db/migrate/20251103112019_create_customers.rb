# frozen_string_literal: true

class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.string :name, null: false
      t.string :email
      t.string :phone, null: false
      t.string :address
      t.string :city
      t.string :state
      t.string :zip_code
      t.text :notes
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :customers, :name
    add_index :customers, :email
    add_index :customers, :active
  end
end
