module Api
  module V1
    class DnsRecordsController < ApplicationController
      # GET /dns_records
      def index
        if params[:page].to_i.zero?
          render json: { error: 'Page number is required' }, status: :unprocessable_entity

          return
        end

        service = DnsRecordsService.new(params)
        dns_records, related_hostnames, all_general_dns_records, all_related_hostnames = service.call

        if params[:included].present? && params[:excluded].present?
          render json: {
            total_records: dns_records.count,
            records: dns_records,
            related_hostnames: related_hostnames
          }
        else
          render json: {
            total_records: all_general_dns_records.count,
            records: all_general_dns_records,
            related_hostnames: all_related_hostnames
          }
        end
      end
      # POST /dns_records
      def create
        @dns_record = DnsRecord.new(permitted_params)

        if @dns_record.save
          render json: { id: @dns_record.id }, status: :created
        else
          render json: { errors: @dns_record.errors.full_messages }, status: :bad_request
        end
      end

      private

      def permitted_params
        params.require(:dns_records).permit(:ip, hostnames_attributes: [:hostname])
      end
    end
  end
end
