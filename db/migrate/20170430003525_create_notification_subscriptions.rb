class CreateNotificationSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :notification_subscriptions do |t|
      t.references :subscriber
      t.references :notification, foreign_key: true
      t.integer :reason_for_subscription
      t.datetime :seen_at

      t.timestamps

      t.index [:notification_id, :subscriber_id],
        name: 'index_notification_subscriptions_on_notification_and_subscriber',
        unique: true
      t.foreign_key :users, column: :subscriber_id
    end
  end
end
