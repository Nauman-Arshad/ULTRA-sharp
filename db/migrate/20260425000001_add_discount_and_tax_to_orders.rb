class AddDiscountAndTaxToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :discount_percent, :decimal, precision: 5, scale: 2, default: 0, null: false
    add_column :orders, :tax_percent, :decimal, precision: 5, scale: 2, default: 0, null: false
  end
end
