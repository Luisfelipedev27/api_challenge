require 'rails_helper'

RSpec.describe Hostname, type: :model do
  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:dns_records) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:hostname) }
  end
end
