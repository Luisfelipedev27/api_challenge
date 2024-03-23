require 'resolv'
class DnsRecord < ApplicationRecord
  has_and_belongs_to_many :hostnames

  validates :ip, :format => { :with => Resolv::AddressRegex }, presence: true

  accepts_nested_attributes_for :hostnames
end
