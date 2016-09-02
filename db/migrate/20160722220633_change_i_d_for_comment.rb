class ChangeIDForComment < ActiveRecord::Migration[5.0]

  ### Migrate comments table over to using UUIDs ###
  # We do this by getting all of the records from the comments table,
  # saving it temporarily, renaming the comments table, creating a new comments
  # table with UUID, and then re-adding all the temporarily saved comments.
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
    remove_foreign_key :comments, :posts

    # drop the old table
    drop_table :comments

    # create table with UUID
    create_table :comments, id: :uuid do |t|
      t.references :author
      t.uuid :post_id, index: true
      t.string :content

      t.timestamps
    end

    # add an index for created_at (so first and last work)
    add_index :comments, :created_at

    # add foreign keys
    add_foreign_key :comments, :users, column: :author_id
    add_foreign_key :comments, :posts

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
    remove_foreign_key :comments, :posts

    # remove index for created_at
    remove_index :comments, :created_at

    # drop the old table
    drop_table :comments

    # create table with ID
    create_table :comments do |t|
      t.references :author
      t.uuid :post_id, index: true
      t.string :content

      t.timestamps
    end

    # add foreign keys
    add_foreign_key :comments, :users, column: :author_id
    add_foreign_key :comments, :posts

    # insert comments
    puts "Attempting to copy over #{comments.size} comment(s)..."
    comments.each do |comment|
      Comment.create(comment)
    end
    puts "Complete."

  end
end
