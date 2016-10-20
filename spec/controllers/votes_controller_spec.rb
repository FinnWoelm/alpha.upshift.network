require 'rails_helper'

RSpec.describe VotesController, type: :controller do

  it { should use_before_action(:authorize) }

end
