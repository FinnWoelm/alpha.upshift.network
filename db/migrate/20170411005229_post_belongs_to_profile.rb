class PostBelongsToProfile < ActiveRecord::Migration[5.0]
  def change
    add_reference :posts, :profile, index: true, foreign_key: true
  end
end
