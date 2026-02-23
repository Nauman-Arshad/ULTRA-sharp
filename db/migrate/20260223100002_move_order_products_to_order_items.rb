# frozen_string_literal: true

class MoveOrderProductsToOrderItems < ActiveRecord::Migration[8.1]
  def up
    # Backfill: one order_item per order from existing order columns
    execute <<-SQL.squish
      INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, line_total, created_at, updated_at)
      SELECT id, product_id, COALESCE(product_name, ''), COALESCE(quantity, 0), COALESCE(unit_price, 0), COALESCE(quantity * unit_price, 0), created_at, updated_at
      FROM orders
      WHERE product_name IS NOT NULL AND product_name != '' AND quantity IS NOT NULL AND quantity > 0
    SQL

    remove_column :orders, :product_id
    remove_column :orders, :product_name
    remove_column :orders, :quantity
    remove_column :orders, :unit_price
  end

  def down
    add_column :orders, :product_id, :bigint
    add_column :orders, :product_name, :string
    add_column :orders, :quantity, :decimal, precision: 14, scale: 2
    add_column :orders, :unit_price, :decimal, precision: 14, scale: 2

    execute <<-SQL.squish
      UPDATE orders o SET
        product_id = (SELECT product_id FROM order_items WHERE order_id = o.id LIMIT 1),
        product_name = (SELECT product_name FROM order_items WHERE order_id = o.id LIMIT 1),
        quantity = (SELECT quantity FROM order_items WHERE order_id = o.id LIMIT 1),
        unit_price = (SELECT unit_price FROM order_items WHERE order_id = o.id LIMIT 1)
      WHERE EXISTS (SELECT 1 FROM order_items WHERE order_id = o.id)
    SQL
  end
end
