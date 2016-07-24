class CreateParticipantshipInPrivateConversations < ActiveRecord::Migration[5.0]
  def change
    create_table :participantship_in_private_conversations do |t|
      t.references :participant, index: false
      t.references :private_conversation, foreign_key: true, type: :uuid, index: false
      t.datetime :read_at

      t.timestamps
      t.index [:participant_id, :private_conversation_id], unique: true, name: 'index_participantship_in_private_conversations_first'
      t.index :private_conversation_id, name: 'index_participantship_in_private_conversations_second'

      t.foreign_key :users, column: :participant_id
    end

  end
end
