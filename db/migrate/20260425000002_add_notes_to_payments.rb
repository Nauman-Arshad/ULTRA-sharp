class AddNotesToPayments < ActiveRecord::Migration[8.1]
  def change
    add_column :payments, :notes, :text
  end
end
