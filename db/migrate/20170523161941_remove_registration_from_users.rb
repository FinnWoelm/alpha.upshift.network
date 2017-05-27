class RemoveRegistrationFromUsers < ActiveRecord::Migration[5.1]
  def up
    remove_index :users, :registration_token
    remove_column :users, :registration_token
    remove_column :users, :confirmed_registration
  end

  def down
    add_column :users, :confirmed_registration, :boolean, default: false, null: false
    add_column :users, :registration_token, :string
    add_index :users, :registration_token, unique: true
  end
end
