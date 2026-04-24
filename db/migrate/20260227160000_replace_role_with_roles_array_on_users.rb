# frozen_string_literal: true

class ReplaceRoleWithRolesArrayOnUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :roles, :string, array: true, default: [], null: false

    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          UPDATE users SET roles = ARRAY[role]::varchar[] WHERE role IS NOT NULL AND role != ''
        SQL
        execute "UPDATE users SET roles = ARRAY['admin']::varchar[] WHERE roles = '{}' OR array_length(roles, 1) IS NULL"
      end
    end

    remove_index :users, name: "index_users_on_role", if_exists: true
    remove_column :users, :role
    add_index :users, :roles, using: "gin"
  end

  def down
    add_column :users, :role, :string, default: "admin", null: false
    add_index :users, :role

    execute <<-SQL.squish
      UPDATE users SET role = roles[1] WHERE array_length(roles, 1) >= 1
    SQL
    execute "UPDATE users SET role = 'admin' WHERE role IS NULL OR role = ''"

    remove_index :users, name: "index_users_on_roles", if_exists: true
    remove_column :users, :roles
  end
end
