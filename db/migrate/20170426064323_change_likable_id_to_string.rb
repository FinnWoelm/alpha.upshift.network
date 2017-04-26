class ChangeLikableIdToString < ActiveRecord::Migration[5.0]
  def up
    change_column :likes, :likable_id, :string
  end

  def down
    change_column :likes, :likable_id, :uuid
  end
end
