class AddCnpjToCompanySettings < ActiveRecord::Migration[7.1]
  def change
    add_column :company_settings, :cnpj, :string
    add_index :company_settings, :cnpj
  end
end
