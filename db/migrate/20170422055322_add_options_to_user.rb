class AddOptionsToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :options, :text
  end
end
