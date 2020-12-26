# frozen_string_literal: true
module CloudPay
  module Kassir
    class State < Namespace
      path_prefix '/kkt/state'

      def update(attributes, options = {})
        run_if_valid(attributes, [:inn, :device_number, :fiscal_number, :on_maintenance], options) do |attributes|
          request(nil, attributes, options)
        end
      end

      def update!(attributes, options = {})
        result = update(attributes, options.merge(raise_error: true))
        result.success?
      end

      def get(attributes, options = {})
        run_if_valid(attributes, [:device_number, :fiscal_number], options) do |attributes|
          request(:get, attributes, options)
        end
      end

      def get!(attributes, _options = {})
        result = get(attributes, raise_error: true)
        result.model
      end
    end
  end
end
