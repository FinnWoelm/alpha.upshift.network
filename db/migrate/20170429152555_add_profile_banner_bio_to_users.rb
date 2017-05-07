class AddProfileBannerBioToUsers < ActiveRecord::Migration[5.0]
  def change
    add_attachment :users, :profile_banner
    add_column :users, :bio, :text
  end
end
