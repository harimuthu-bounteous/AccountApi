class ChangeUserIdToUuid < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :uuid, :uuid, default: 'gen_random_uuid()', null: false

    remove_foreign_key :accounts, :users
    rename_column :accounts, :user_id, :old_user_id
    add_column :accounts, :user_id, :uuid

    # Todo: Replace the SQL with Rails code.
    execute <<-SQL
      UPDATE accounts
      SET user_id = users.uuid
      FROM users
      WHERE accounts.old_user_id = users.id
    SQL
    # ____________________________________________

    remove_column :accounts, :old_user_id

    add_foreign_key :accounts, :users, column: :user_id

    remove_column :users, :id
    rename_column :users, :uuid, :id
    execute "ALTER TABLE users ADD PRIMARY KEY (id);"
  end
end
