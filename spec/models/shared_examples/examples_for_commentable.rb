RSpec.shared_examples "a commentable object" do

  describe "associations" do
    it { is_expected.to have_many(:comments).dependent(:delete_all) }
  end

end
