class DnsRecordsService
  def initialize(params)
    @included_hostnames = params[:included]&.split(',')
    @excluded_hostnames = params[:excluded]&.split(',')
    @page_number = params[:page].to_i
  end

  def call
    dns_records = fetch_dns_records
    related_hostnames = fetch_related_hostnames(dns_records)
    all_general_dns_records = fetch_all_general_dns_records
    all_related_hostnames = fetch_all_related_hostnames

    [dns_records, related_hostnames, all_general_dns_records, all_related_hostnames]
  end

  private

  def fetch_dns_records
    records = DnsRecord.joins(:hostnames)
                        .where.not(hostnames: { hostname: @excluded_hostnames })
                        .where(hostnames: { hostname: @included_hostnames })
                        .distinct
                        .page(@page_number)

    records.map { |record| { id: record.id, ip_address: record.ip } }
  end

  def fetch_related_hostnames(dns_records)
    related_hostnames = Hostname.joins(:dns_records)
                                .where(dns_records: { id: dns_records.pluck(:id) }, hostname: @included_hostnames )
                                .where.not(hostname: @excluded_hostnames)
                                .group(:hostname)
                                .count

    related_hostnames.map { |hostname, count| { hostname: hostname, count: count } }
  end

  def fetch_all_general_dns_records
    all_general_dns_records = DnsRecord.joins(:hostnames).distinct

    all_general_dns_records.sort_by { |record| record[:id] }.map { |record| { id: record.id, ip_address: record.ip } }
  end

  def fetch_all_related_hostnames
    dns_records_with_hostnames = DnsRecord.joins(:hostnames)
                                          .where(id: fetch_all_general_dns_records.pluck(:id))
                                          .order(:id)
                                          .pluck(:id, 'hostnames.hostname')

    hostnames_in_order = dns_records_with_hostnames.map(&:second).uniq

    hostname_counts = Hostname.joins(:dns_records)
                              .where(dns_records: { id: fetch_all_general_dns_records.pluck(:id) })
                              .group(:hostname)
                              .count

    hostnames_in_order.map { |hostname| { hostname: hostname, count: hostname_counts[hostname] } }
  end
end
