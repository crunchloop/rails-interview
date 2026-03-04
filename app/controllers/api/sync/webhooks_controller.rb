module Api
  module Sync
    class WebhooksController < ApplicationController
      skip_before_action :verify_authenticity_token

      VALID_EVENTS         = %w[created updated deleted].freeze
      VALID_RESOURCE_TYPES = %w[todo_list todo_item].freeze

      def create
        unless valid_signature?
          Rails.logger.warn("[ExternalSync::Webhook] Invalid signature from #{request.remote_ip}")
          return head :unauthorized
        end

        payload = webhook_params

        unless valid_payload?(payload)
          return render json: { error: "Invalid payload" }, status: :unprocessable_entity
        end

        ::Sync::InboundSyncJob.perform_later(payload.to_h)

        head :ok
      end

      private

      def webhook_params
        params.require(:webhook).permit(:event, :resource_type, data: {})
      rescue ActionController::ParameterMissing
        params.permit(:event, :resource_type, data: {})
      end

      def valid_payload?(payload)
        VALID_EVENTS.include?(payload[:event]) &&
          VALID_RESOURCE_TYPES.include?(payload[:resource_type]) &&
          payload[:data].present?
      end

      def valid_signature?
        secret = ENV["WEBHOOK_SECRET"]
        return true if secret.blank?

        received  = request.headers["X-Webhook-Secret"]
        ActiveSupport::SecurityUtils.secure_compare(secret, received.to_s)
      end
    end
  end
end
