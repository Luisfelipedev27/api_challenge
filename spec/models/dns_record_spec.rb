require 'rails_helper'

RSpec.describe DnsRecord, type: :model do
  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:hostnames) }
    it { is_expected.to accept_nested_attributes_for(:hostnames) }
  end
end
