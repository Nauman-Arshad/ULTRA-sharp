class AddUniqueIndexToPartiesPhone < ActiveRecord::Migration[8.1]
  def change
    add_index :parties, :phone, unique: true, where: "phone IS NOT NULL"
  end
end

