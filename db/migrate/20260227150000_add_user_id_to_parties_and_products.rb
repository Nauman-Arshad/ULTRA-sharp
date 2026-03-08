# frozen_string_literal: true

class AddUserIdToPartiesAndProducts < ActiveRecord::Migration[8.1]
  def change
    add_reference :parties, :user, null: true, foreign_key: true
    add_reference :products, :user, null: true, foreign_key: true

    reversible do |dir|
      dir.up do
        first_user_id = select_value("SELECT id FROM users ORDER BY id ASC LIMIT 1")
        if first_user_id
          execute "UPDATE parties SET user_id = #{connection.quote(first_user_id)}"
          execute "UPDATE products SET user_id = #{connection.quote(first_user_id)}"
        end
        change_column_null :parties, :user_id, false
        change_column_null :products, :user_id, false
        remove_index :parties, name: "index_parties_on_phone"
        add_index :parties, %i[user_id phone], unique: true, name: "index_parties_on_user_id_and_phone", where: "phone IS NOT NULL"
      end
      dir.down do
        remove_index :parties, name: "index_parties_on_user_id_and_phone"
        add_index :parties, :phone, unique: true, where: "phone IS NOT NULL"
      end
    end
  end
end
