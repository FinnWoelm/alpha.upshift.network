class AddcolorSchemeToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :color_scheme, :string, :null => false, :default => "indigo basic"
  end
end
