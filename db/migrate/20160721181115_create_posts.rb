class CreatePosts < ActiveRecord::Migration[5.0]
  def change

    create_table :posts, id: :uuid do |t|
      t.references :author
      t.text :content, null: false

      t.timestamps
    end

    add_index :posts, :created_at

  end
end
