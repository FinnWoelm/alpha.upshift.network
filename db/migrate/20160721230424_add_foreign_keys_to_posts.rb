class AddForeignKeysToPosts < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :posts, :users, column: :author_id
  end
end
