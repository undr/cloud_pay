# frozen_string_literal: true
module CloudPay
  module Payments
    class Main < Namespace
      path_prefix '/payments'

      def cards
        Cards.new(client)
      end

      def tokens
        Tokens.new(client)
      end

      def confirm(id, attributes, options = {})
        run_if_valid(attributes.merge(transaction_id: id), [:transaction_id, :amount], options) do |attributes|
          request(:confirm, attributes, options)
        end
      end

      def confirm!(id, attributes, options = {})
        result = confirm(id, attributes, options.merge(raise_error: true))
        result.success?
      end

      def void(id, options = {})
        run_if_valid({ transaction_id: id }, options) do |attributes|
          request(:void, attributes, options)
        end
      end

      def void!(id, options = {})
        result = void(id, options.merge(raise_error: true))
        result.success?
      end

      alias :cancel :void
      alias :cancel! :void!

      def refund(id, attributes, options = {})
        run_if_valid(attributes.merge(transaction_id: id), [:transaction_id, :amount], options) do |attributes|
          request(:refund, attributes, options)
        end
      end

      def refund!(id, attributes, options = {})
        result = refund(id, attributes, options.merge(raise_error: true))
        result.model
      end

      def get(id, options = {})
        run_if_valid({ transaction_id: id }, options) do |attributes|
          request(:get, attributes, options)
        end
      end

      def get!(id, options = {})
        result = get(id, options.merge(raise_error: true))
        result.model
      end

      def find(invoice_id, options = {})
        run_if_valid({ invoice_id: invoice_id }, options) do |attributes|
          options = options.merge(path_prefix: '/v2/payments') if options[:version] == 2
          request(:find, attributes, options)
        end
      end

      def find!(invoice_id, options = {})
        result = find(invoice_id, options.merge(raise_error: true))
        result.model
      end

      def list(attributes, options = {})
        run_if_valid(attributes, [:date], options) do |attributes|
          request(:list, attributes, options)
        end
      end

      def list!(attributes, options = {})
        result = list(attributes, options.merge(raise_error: true))
        result.model
      end
    end
  end
end
