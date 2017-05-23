class CreateAccounts < ActiveRecord::Migration[5.1]
  def up
    create_table :accounts do |t|
      t.citext :email, :null => false
      t.string :password_digest
    end
    add_index :accounts, :email, unique: true
    add_reference :users, :account, foreign_key: true

    User.find_each do |user|
      user.create_account(:email => user.email, :password_digest => user.password_digest)
    end

    remove_index :users, :email
    remove_column :users, :email
    remove_column :users, :password_digest
  end

  def down
    add_column :users, :password_digest, :string
    add_column :users, :email, :citext
    add_index :users, :email, unique: true

    Account.includes(:user).find_each do |account|
      account.user.update_attributes(:email => account.email, :password_digest => account.password_digest)
    end

    remove_index :accounts, :email
    remove_reference :users, :account, foreign_key: true
    drop_table :accounts
  end
end
