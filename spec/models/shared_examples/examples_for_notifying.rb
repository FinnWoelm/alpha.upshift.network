RSpec.shared_examples "a notifying object" do

  describe "callbacks" do

    describe "after create" do
      after { subject.save }

      it { is_expected.to receive(:create_notification) }
    end

    describe "after destroy" do
      after do
        subject.save
        subject.destroy
      end

      it { is_expected.to receive(:destroy_notification) }
    end
  end

  describe "when actions are re-initalized" do

    it "does not raise an error" do
      subject.save
      notification = Notification.last
      expect{ notification.reinitialize_actions }.not_to raise_error
    end
  end
end
