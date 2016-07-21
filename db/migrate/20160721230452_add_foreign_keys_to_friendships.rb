class AddForeignKeysToFriendships < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :friendships, :users, column: :acceptor_id
    add_foreign_key :friendships, :users, column: :initiator_id
  end
end
