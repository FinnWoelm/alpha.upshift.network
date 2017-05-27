class EnableUnaccentExtension < ActiveRecord::Migration[5.1]
  def up
    enable_extension 'unaccent'
  end

  def down
    disable_extension 'unaccent'
  end
end
