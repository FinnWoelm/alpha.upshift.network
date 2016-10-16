class MakeCommentPolymorphic < ActiveRecord::Migration[5.0]
  def up
    rename_column :comments, :post_id, :commentable_id
    add_column :comments, :commentable_type, :string

    # Remove foreign key comments on posts
    remove_foreign_key :comments, :posts

    # Create index
    add_index :comments, [:commentable_type, :commentable_id]

    # Set commentable types to Post on existing comments
    Comment.reset_column_information
    Comment.update_all(:commentable_type => "Post")
  end

  def down

    Comment.where.not(:commentable_type => "Post").destroy_all

    remove_index :comments, [:commentable_type, :commentable_id]

    rename_column :comments, :commentable_id , :post_id
    remove_column :comments, :commentable_type

    # Add foreign key
    add_foreign_key :comments, :posts
  end
end
