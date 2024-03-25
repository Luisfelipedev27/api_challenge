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
        service = Api::V1::DnsRecords::Creator.call(permitted_params)

        if service.success?
          render json: { id: service.dns_records.id }, status: :created
        else
          render json: { errors: service.error_message }, status: :bad_request
        end
      end

      private

      def permitted_params
        params.require(:dns_records).permit(:ip, hostnames_attributes: [:hostname])
      end
    end
  end
end
