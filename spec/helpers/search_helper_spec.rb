require 'rails_helper'

RSpec.describe SearchHelper, type: :helper do

  describe "#highlight_query_in" do

    it "ignores accents" do
      expect(helper.highlight_query_in("Äléõ", "Aleo")).
        to include "<u>"
      expect(helper.highlight_query_in("Aleo", "Äléõ")).
        to include "<u>"
    end

    it "ignores case" do
      expect(helper.highlight_query_in("AlIcE", "alice")).
        to include "<u>"
      expect(helper.highlight_query_in("alice", "ALIcE")).
        to include "<u>"
    end

    it "requires that all words in the query match" do
      expect(helper.highlight_query_in("Alice", "Alice Carla")).
        not_to include "<u>"
      expect(helper.highlight_query_in("Alice Carla", "Alice Carla the Second")).
        not_to include "<u>"
      expect(helper.highlight_query_in("Alice Carla the Second", "Alice Carla the Second")).
        to include "<u>"
    end
  end
end
