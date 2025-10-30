class CreateCompanySettings < ActiveRecord::Migration[7.1]
  def change
    create_table :company_settings do |t|
      t.string :company_name
      t.text :address
      t.string :phone
      t.string :email
      t.string :website
      t.string :logo_filename
      t.binary :logo_data, limit: 5.megabytes

      t.timestamps
    end
  end
end
