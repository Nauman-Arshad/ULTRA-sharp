# frozen_string_literal: true

class MakePaymentsOrderIdOptional < ActiveRecord::Migration[8.1]
  def change
    change_column_null :payments, :order_id, true
  end
end
