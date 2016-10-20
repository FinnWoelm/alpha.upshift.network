class CreateVotes < ActiveRecord::Migration[5.0]
  def change
    create_table :votes do |t|
      t.references :voter
      t.uuid :votable_id
      t.string :votable_type
      t.integer :vote, default: 0
      t.timestamps
    end

    add_index :votes, [:votable_type, :votable_id]

    add_foreign_key :votes, :users, column: :voter_id

  end
end
