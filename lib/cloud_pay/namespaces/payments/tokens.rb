# frozen_string_literal: true
module CloudPay
  module Payments
    class Tokens < Namespace
      path_prefix '/payments/tokens'

      def charge(attributes, options = {})
        run_if_valid(attributes, [:amount, :account_id, :token], options) do |attributes|
          request(:charge, attributes, options)
        end
      end

      def charge!(attributes, options = {})
        result = charge(attributes, options.merge(raise_error: true))
        result.model
      end

      def auth(attributes, options = {})
        run_if_valid(attributes, [:amount, :account_id, :token], options) do |attributes|
          request(:auth, attributes, options)
        end
      end

      def auth!(attributes, options = {})
        result = auth(attributes, options.merge(raise_error: true))
        result.model
      end

      def topup(attributes, options = {})
        run_if_valid(attributes, [:token, :amount, :account_id, :currency], options) do |attributes|
          # TODO: Check if official documentation has a typo here
          # https://developers.cloudpayments.ru/en/#payout-by-a-token
          # request(:topup, attributes, options.merge(path_prefix: '/payments/token'))
          request(:topup, attributes, options)
        end
      end

      def topup!(attributes, options = {})
        result = topup(attributes, options.merge(raise_error: true))
        result.model
      end

      def list(options = {})
        request(:list, nil, options)
      end

      def list!(_options = {})
        list(raise_error: true).model
      end
    end
  end
end
