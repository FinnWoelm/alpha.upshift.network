require 'rails_helper'

RSpec.describe VotesController do

  it { is_expected.to use_before_action(:authorize) }

end
