class CreatePrivateConversations < ActiveRecord::Migration[5.0]
  def change
    create_table :private_conversations, id: :uuid do |t|

      t.timestamps

      # Since we are using type UUID, we need to index the date of creation
      t.index :created_at
    end

  end
end
