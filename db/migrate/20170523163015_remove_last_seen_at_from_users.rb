class RemoveLastSeenAtFromUsers < ActiveRecord::Migration[5.1]
  def up
    remove_column :users, :last_seen_at
  end

  def down
    add_column :users, :last_seen_at, :datetime
  end
end
