class AddConfirmedRegistrationRegistrationTokenToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :confirmed_registration, :boolean, default: false, null: false
    add_column :users, :registration_token, :string
    add_index :users, :registration_token, unique: true
  end
end
