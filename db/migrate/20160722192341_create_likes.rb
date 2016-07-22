class CreateLikes < ActiveRecord::Migration[5.0]
  def change
    create_table :likes do |t|
      t.references :liker
      t.uuid :likable_id
      t.string  :likable_type
      t.timestamps
    end

    add_index :likes, [:likable_type, :likable_id]

    add_foreign_key :likes, :users, column: :liker_id

  end
end
