# frozen_string_literal: true

class AddProductIdToOrders < ActiveRecord::Migration[8.1]
  def change
    add_reference :orders, :product, null: true, foreign_key: true
  end
end
