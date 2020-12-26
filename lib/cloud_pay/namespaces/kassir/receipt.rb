# frozen_string_literal: true
module CloudPay
  module Kassir
    class Receipt < Namespace
      path_prefix '/kkt/receipt'

      def create(attributes, options = {})
        run_if_valid(attributes, [:inn, :type, :customer_receipt], options) do |attributes|
          request(nil, attributes, options)
        end
      end

      def create!(attributes, options = {})
        result = create(attributes, options.merge(raise_error: true))
        result.model
      end

      def status(id, options = {})
        run_if_valid({ id: id }, options) do |attributes|
          request('status/get', attributes, options)
        end
      end

      def status!(id, _options = {})
        result = status(id, raise_error: true)
        result.model
      end

      def get(id, options = {})
        run_if_valid({ id: id }, options) do |attributes|
          request(:get, attributes, options)
        end
      end

      def get!(id, _options = {})
        result = get(id, raise_error: true)
        result.model
      end
    end
  end
end
