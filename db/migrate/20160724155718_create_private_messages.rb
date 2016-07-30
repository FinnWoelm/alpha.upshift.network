class CreatePrivateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :private_messages do |t|
      t.belongs_to :private_conversation, foreign_key: true, type: :uuid
      t.belongs_to :sender
      t.string :content

      t.timestamps
    end

    add_foreign_key :private_messages, :users, column: :sender_id

  end
end
