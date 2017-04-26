class ChangeIdForComment < ActiveRecord::Migration[5.0]

  ### Migrate comments table over to using IDs ###
  # We do this by getting all of the records from the comments table,
  # saving it temporarily, renaming the comments table, creating a new comments
  # table with ID, and then re-adding all the temporarily saved comments.
  # Finally, the old comments table is dropped and the migration is finished.
  # THe whole procedure is reversed when we rollback.
  def up
    # fetch all comments
    comments = []
    Comment.all.each do |comment|
      comments << comment.serializable_hash(:except => 'id')
    end

    # remove foreign keys
    remove_foreign_key :comments, :users

    # remove index for created_at
    remove_index :comments, :created_at

    # drop the old table
    drop_table :comments

    # create table with ID
    create_table :comments do |t|
      t.references :author
      t.string :commentable_id
      t.string :commentable_type
      t.string :content
      t.integer :likes_count, :default => 0

      t.timestamps
    end

    # add foreign keys
    add_foreign_key :comments, :users, column: :author_id
    add_index :comments, [:commentable_type, :commentable_id]

    # insert comments
    puts "Attempting to copy over #{comments.size} comment(s)..."
    comments.each do |comment|
      Comment.create(comment)
    end
    puts "Complete."

  end

  def down
    # fetch all comments
    comments = []
    Comment.all.each do |comment|
      comments << comment.serializable_hash(:except => 'id')
    end

    # remove foreign keys
    remove_foreign_key :comments, :users

    # drop the old table
    drop_table :comments

    # create table with UUID
    create_table :comments, id: :uuid do |t|
      t.references :author
      t.references :commentable, polymorphic: true,  type: :uuid, index: true
      t.string :content
      t.integer :likes_count, :default => 0

      t.timestamps

      t.index :created_at
    end

    # add foreign keys
    add_foreign_key :comments, :users, column: :author_id

    # insert comments
    puts "Attempting to copy over #{comments.size} comment(s)..."
    comments.each do |comment|
      Comment.create(comment)
    end
    puts "Complete."
  end
end
