class CreateDemocracyCommunities < ActiveRecord::Migration[5.0]
  def change
    create_table :democracy_communities, id: :uuid do |t|
      t.string :name

      t.timestamps

      # Since we are using type UUID, we need to index the date of creation
      t.index :created_at
    end
  end
end
