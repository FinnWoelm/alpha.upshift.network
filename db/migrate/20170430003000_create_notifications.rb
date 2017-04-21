class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.string :notifier_type
      t.string :notifier_id
      t.integer :action_on_notifier
      t.datetime :others_acted_before

      t.timestamps

      t.index [:notifier_type, :notifier_id, :action_on_notifier],
        name: 'index_notifications_on_notifier_and_action',
        unique: true
    end
  end
end
