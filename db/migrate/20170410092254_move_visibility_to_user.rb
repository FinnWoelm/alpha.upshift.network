class MoveVisibilityToUser < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :visibility, :integer, default: 0

    User.includes(:profile).find_each do |user|
      user.update(:visibility => User.visibilities[user.profile.visibility])
    end

    remove_column :profiles, :visibility
  end

  def down
    add_column :profiles, :visibility, :integer, default: 0

    User.includes(:profile).find_each do |user|
      user.profile.update(:visibility => Profile.visibilities[user.visibility])
    end

    remove_column :users, :visibility
  end
end
