class RenameNameToUsernameInUsers < ActiveRecord::Migration[7.2]
  def change
    rename_column :users, :name, :username
  end
end
