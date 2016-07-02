class ChangeUsernameColumnToCitext < ActiveRecord::Migration[5.0]

  def up
    enable_extension 'citext'
    change_column :users, :username, :citext, :null => false
  end

  def down
    change_column :users, :username, :string
    disable_extension 'citext'
  end

end
