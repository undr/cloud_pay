# frozen_string_literal: true
module CloudPay
  module Kassir
    class Main < Namespace
      path_prefix '/kkt'

      def fiscalize(attributes, options = {})
        run_if_valid(attributes, [
          :inn,
          :device_number,
          :fiscal_number,
          :reg_number,
          :url,
          :ofd,
          :taxation_system,
          :merchant_email
        ], options) do |attributes|
          request(:fiscalize, attributes, options)
        end
      end

      def fiscalize!(attributes, options = {})
        result = fiscalize(attributes, options.merge(raise_error: true))
        result.success?
      end

      def receipt
        Receipt.new(client)
      end

      def state
        State.new(client)
      end
    end
  end
end
