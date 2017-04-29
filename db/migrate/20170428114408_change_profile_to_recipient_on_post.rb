class ChangeProfileToRecipientOnPost < ActiveRecord::Migration[5.0]
  def up
    add_reference :posts, :recipient, index: true
    add_foreign_key :posts, :users, column: :recipient_id
    Post.includes(:profile).find_each do |post|
      post.update(:recipient_id => post.profile_owner.id)
    end
    remove_foreign_key :posts, :profiles
    remove_reference :posts, :profile
  end

  def down
    add_reference :posts, :profile, index: true, foreign_key: true
    Post.includes(recipient: [:profile]).find_each do |post|
      post.update(:profile_id => post.recipient.profile.id)
    end
    remove_foreign_key :posts, column: :recipient_id
    remove_reference :posts, :recipient
  end
end
