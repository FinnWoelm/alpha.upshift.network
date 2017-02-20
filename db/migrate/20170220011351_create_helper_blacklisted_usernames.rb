class CreateHelperBlacklistedUsernames < ActiveRecord::Migration[5.0]
  def change
    create_table :helper_blacklisted_usernames do |t|
      t.citext :username, :null => false

      t.timestamps
    end
    add_index :helper_blacklisted_usernames, :username, unique: true
  end
end
