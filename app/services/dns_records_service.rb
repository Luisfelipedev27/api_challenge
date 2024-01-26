class DnsRecordsService
  def initialize(params)
    @included_hostnames = params[:included]&.split(',')
    @excluded_hostnames = params[:excluded]&.split(',')
    @page_number = params[:page].to_i
  end

  def call
    dns_records = fetch_dns_records
    related_hostnames = fetch_related_hostnames(dns_records)

    [dns_records, related_hostnames]
  end

  private

  def fetch_dns_records
    DnsRecord.joins(:hostnames)
             .where.not(hostnames: { hostname: @excluded_hostnames })
             .where(hostnames: { hostname: @included_hostnames })
             .distinct
             .page(@page_number)
  end

  def fetch_related_hostnames(dns_records)
    Hostname.joins(:dns_records)
            .where(dns_records: { id: dns_records.pluck(:id) }, hostname: @included_hostnames )
            .where.not(hostname: @excluded_hostnames)
            .group(:hostname)
            .count
  end
end
