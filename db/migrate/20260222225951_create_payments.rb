class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :party, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.decimal :amount, precision: 14, scale: 2
      t.date :payment_date

      t.timestamps
    end
  end
end
