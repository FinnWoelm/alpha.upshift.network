class CreatePendingNewsletterSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :pending_newsletter_subscriptions do |t|
      t.string :name
      t.string :email
      t.string :confirmation_token
      t.string :signup_url
      t.string :ip_address

      t.timestamps
    end
    add_index :pending_newsletter_subscriptions, :confirmation_token, unique: true
    add_index :pending_newsletter_subscriptions, :email, unique: true
  end
end
