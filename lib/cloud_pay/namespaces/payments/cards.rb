# frozen_string_literal: true
module CloudPay
  module Payments
    class Cards < Namespace
      path_prefix '/payments/cards'

      def charge(attributes, options = {})
        run_if_valid(attributes, [:amount, :ip_address, :card_cryptogram_packet], options) do |attributes|
          request(:charge, attributes, options)
        end
      end

      def charge!(attributes, options = {})
        result = charge(attributes, options.merge(raise_error: true))
        result.model
      end

      def auth(attributes, options = {})
        run_if_valid(attributes, [:amount, :ip_address, :card_cryptogram_packet], options) do |attributes|
          request(:auth, attributes, options)
        end
      end

      def auth!(attributes, options = {})
        result = auth(attributes, options.merge(raise_error: true))
        result.model
      end

      def post3ds(id, attributes, options = {})
        run_if_valid(attributes.merge({ transaction_id: id }), [:transaction_id, :pa_res], options) do |attributes|
          request(:post3ds, attributes, options)
        end
      end

      def post3ds!(id, attributes, options = {})
        result = post3ds(id, attributes, options.merge(raise_error: true))
        result.model
      end

      def topup(attributes, options = {})
        run_if_valid(
          attributes,
          [:name, :amount, :card_cryptogram_packet, :account_id, :currency],
          options
        ) do |attributes|
          request(:topup, attributes, options)
        end
      end

      def topup!(attributes, options = {})
        result = topup(attributes, options.merge(raise_error: true))
        result.model
      end
    end
  end
end
