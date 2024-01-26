module Api
  module V1
    class DnsRecordsController < ApplicationController
      # GET /dns_records
      def index
        if params[:page].to_i.nil? || params[:page].to_i == 0
          render json: { error: 'page number is required' }, status: :bad_request

          return
        end

        service = DnsRecordsService.new(params)
        dns_records, related_hostnames = service.call

        render json: {
          total_records: dns_records.count,
          records: dns_records.map { |record| { id: record.id, ip_address: record.ip } },
          related_hostnames: related_hostnames.map { |hostname, count| { hostname: hostname, count: count } }
        }
      end

      # POST /dns_records
      def create
        @dns_record = DnsRecord.new(permitted_params)

        if @dns_record.save
          render json: { id: @dns_record.id }, status: :created
        else
          render :new, status: :bad_request
        end
      end

      private

      def permitted_params
        params.require(:dns_records).permit(:ip, hostnames_attributes: [:hostname])
      end
    end
  end
end
