class CreateTechnicians < ActiveRecord::Migration[7.1]
  def change
    create_table :technicians do |t|
      t.string :name, null: false
      t.string :email
      t.string :phone
      t.string :specialty
      t.text :notes
      t.boolean :active, default: true
      t.references :user, foreign_key: true

      t.timestamps
    end

    add_index :technicians, :name
    add_index :technicians, :email, unique: true, where: "email IS NOT NULL"
    add_index :technicians, :active
  end
end
