module Api
  module V1
    class DnsRecordsController < ApplicationController
      # GET /dns_records
      def index
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
