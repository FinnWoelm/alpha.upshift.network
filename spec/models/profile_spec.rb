require 'rails_helper'

RSpec.describe Profile, type: :model do

  it {
    should define_enum_for(:visibility).
      with([:is_private, :is_network_only, :is_public])
  }

end
