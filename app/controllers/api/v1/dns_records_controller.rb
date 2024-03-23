module Api
  module V1
    class DnsRecordsController < ApplicationController
      def index
        if params[:page].to_i.zero?
          render json: { error: 'Page number is required' }, status: :unprocessable_entity

          return
        end
        service = Api::V1::DnsRecords::Fetcher.call(params)

        render json: {
          total_records: service.dns_records.count,
          records: service.dns_records,
          related_hostnames: service.hostnames
        }
      end

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
