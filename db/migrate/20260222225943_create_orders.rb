class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.string :order_number
      t.references :party, null: false, foreign_key: true
      t.string :product_name
      t.decimal :quantity, precision: 14, scale: 2
      t.decimal :unit_price, precision: 14, scale: 2
      t.decimal :total_amount, precision: 14, scale: 2
      t.decimal :advance_payment, precision: 14, scale: 2
      t.decimal :remaining_amount, precision: 14, scale: 2
      t.string :order_status
      t.string :payment_status
      t.date :order_date

      t.timestamps
    end
  end
end
