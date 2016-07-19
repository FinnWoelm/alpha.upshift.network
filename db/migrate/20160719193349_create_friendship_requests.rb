class CreateFriendshipRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :friendship_requests do |t|
      t.integer :sender_id, foreign_key: true, index: true
      t.integer :recipient_id, foreign_key: true, index: true

      t.timestamps
    end
  end
end
