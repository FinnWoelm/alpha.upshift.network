class AddVotesCountToDemocracyCommunityDecision < ActiveRecord::Migration[5.0]
  def change
    add_column :democracy_community_decisions, :votes_count, :text, :default => {:total => 0, :upvotes => 0, :downvotes => 0}.to_yaml
  end
end
