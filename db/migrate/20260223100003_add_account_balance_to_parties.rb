# frozen_string_literal: true

class AddAccountBalanceToParties < ActiveRecord::Migration[8.1]
  def up
    add_column :parties, :account_balance, :decimal, precision: 14, scale: 2, default: 0, null: false

    # Backfill from existing orders and payments
    execute <<-SQL.squish
      UPDATE parties
      SET account_balance = COALESCE(
        (SELECT SUM(o.total_amount) FROM orders o WHERE o.party_id = parties.id),
        0
      ) - COALESCE(
        (SELECT SUM(p.amount) FROM payments p WHERE p.party_id = parties.id),
        0
      )
    SQL
  end

  def down
    remove_column :parties, :account_balance
  end
end
