module Api
  module V1
    module DnsRecords
      class Fetcher
        attr_reader :dns_records, :hostnames, :error_message

        def initialize(params)
          @page_number = params[:page].to_i
        end

        def self.call(*args)
          new(*args).call
        end

        def call
          fetch_dns_records && fetch_hostnames

          self
        end

        def success?
          error_message.blank?
        end

        private

        attr_writer :dns_records, :hostnames, :error_message

        def fetch_dns_records
          self.dns_records = DnsRecord.all
                                      .joins(:hostnames)
                                      .distinct
                                      .page(@page_number)
                                      .sort_by { |record| record[:id] }
                                      .map { |record| { id: record.id, ip_address: record.ip } }


          true
        end

        def fetch_hostnames
          hostname_counts = Hostname.joins(:dns_records)
                                    .where(dns_records: { id: dns_records.pluck(:id) })
                                    .group(:hostname)
                                    .count

          self.hostnames = DnsRecord.joins(:hostnames)
                                    .where(id: dns_records.pluck(:id))
                                    .order(:id)
                                    .pluck(:id, 'hostnames.hostname')
                                    .map(&:second)
                                    .uniq
                                    .map { |hostname| { hostname: hostname, count: hostname_counts[hostname] } }

        end
      end
    end
  end
end
