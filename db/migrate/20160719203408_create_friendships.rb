class CreateFriendships < ActiveRecord::Migration[5.0]
  def change
    create_table :friendships do |t|
      t.integer :initiator_id, foreign_key: true, index: true
      t.integer :acceptor_id, foreign_key: true, index: true

      t.timestamps
    end
  end
end
