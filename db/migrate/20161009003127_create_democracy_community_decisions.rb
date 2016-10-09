class CreateDemocracyCommunityDecisions < ActiveRecord::Migration[5.0]
  def change
    create_table :democracy_community_decisions, id: :uuid do |t|
      t.belongs_to :community, type: :uuid
      t.belongs_to :author
      t.string :title
      t.text :description
      t.datetime :ends_at

      t.timestamps

      # Since we are using type UUID, we need to index the date of creation
      t.index :created_at
    end

    add_foreign_key :democracy_community_decisions, :users, column: :author_id
    add_foreign_key :democracy_community_decisions, :democracy_communities, column: :community_id

  end
end
