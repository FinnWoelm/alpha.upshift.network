class CreateProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :profiles do |t|
      t.belongs_to :user, foreign_key: true
      t.integer :visibility, default: 0

      t.timestamps
    end
  end
end
