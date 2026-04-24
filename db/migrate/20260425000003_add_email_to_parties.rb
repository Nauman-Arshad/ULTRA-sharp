class AddEmailToParties < ActiveRecord::Migration[8.1]
  def change
    add_column :parties, :email, :string
  end
end
