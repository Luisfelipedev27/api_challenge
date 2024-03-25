module Api
  module V1
    module DnsRecords
      class Creator
        attr_reader :dns_records, :error_message

        def initialize(permitted_params)
          self.permmited_params = permitted_params
        end

        def self.call(*args)
          new(*args).call
        end

        def call
          create_dns_records

          self
        end

        def success?
          error_message.blank?
        end

        private

        attr_writer :dns_records, :error_message

        attr_accessor :permmited_params

        def create_dns_records
          self.dns_records = DnsRecord.create!(ip: permmited_params[:ip], hostnames_attributes: permmited_params[:hostnames_attributes])

          true
        rescue ActiveRecord::RecordInvalid => e
          self.error_message = 'error on create dns record'

          false
        end
      end
    end
  end
end
