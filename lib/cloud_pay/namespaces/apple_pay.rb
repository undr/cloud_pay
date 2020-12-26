# frozen_string_literal: true
module CloudPay
  class ApplePay < Namespace
    path_prefix '/applepay'

    def start_session(attributes, options = {})
      run_if_valid(attributes, [:validation_url], options) do |attributes|
        request(:startsession, attributes, options)
      end
    end

    def start_session!(attributes, options = {})
      result = start_session(attributes, options.merge(raise_error: true))
      result.model
    end
  end
end
