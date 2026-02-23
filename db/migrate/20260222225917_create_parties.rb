class CreateParties < ActiveRecord::Migration[8.1]
  def change
    create_table :parties do |t|
      t.string :party_name
      t.string :phone
      t.text :address
      t.string :status

      t.timestamps
    end
  end
end
