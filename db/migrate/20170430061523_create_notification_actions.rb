class CreateNotificationActions < ActiveRecord::Migration[5.0]
  def change
    create_table :notification_actions do |t|
      t.references :actor, index: false
      t.references :notification, foreign_key: true, index: false

      t.timestamps

      t.index :created_at
      t.index [:notification_id, :actor_id], unique: true
      t.foreign_key :users, column: :actor_id
    end
  end
end
