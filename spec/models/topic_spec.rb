require 'rails_helper'

RSpec.describe Topic, type: :model do

  describe 'associations' do
    it { should have_many(:uploadlinks) }
    it { should have_many(:uploads) }
  end

end
