# frozen_string_literal: true

class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.decimal :unit_price, precision: 14, scale: 2, null: false, default: 0

      t.timestamps
    end
  end
end
