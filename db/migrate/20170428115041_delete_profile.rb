class DeleteProfile < ActiveRecord::Migration[5.0]
  def up
    remove_foreign_key :profiles, :users
    drop_table :profiles
  end

  def down
    create_table :profiles do |t|
      t.belongs_to :user, foreign_key: true

      t.timestamps
    end
  end
end
