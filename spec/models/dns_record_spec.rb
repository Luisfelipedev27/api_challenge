require 'rails_helper'

RSpec.describe DnsRecord, type: :model do
  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:hostnames) }
    it { is_expected.to accept_nested_attributes_for(:hostnames) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:ip) }
    it { is_expected.to allow_value('1.1.1.1').for(:ip) }
    it { is_expected.not_to allow_value('invalid_ip').for(:ip) }
  end
end
