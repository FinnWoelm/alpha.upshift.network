class AddForeignKeysToFriendshipRequests < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :friendship_requests, :users, column: :sender_id
    add_foreign_key :friendship_requests, :users, column: :recipient_id    
  end
end
