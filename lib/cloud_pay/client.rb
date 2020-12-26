# frozen_string_literal: true
require 'cloud_pay/client/response'
require 'cloud_pay/client/key_converter'
require 'cloud_pay/client/serializer'

module CloudPay
  class Client
    include Namespaces

    attr_reader :config, :connection

    def initialize(config = nil)
      @config = CloudPay.config(config)
      @connection = build_connection
    end

    def perform_request(path, params, options = {})
      idempotency_key = options[:idempotency_key]

      connection.basic_auth(config.public_key, config.secret_key)
      response = connection.post(path, (params ? convert_to_json(params) : nil), headers(idempotency_key))

      Response.new(response.status, response.body, response.headers).tap do |response|
        raise_transport_error(response) if response.status.to_i >= 300
      end
    end

    private

    def convert_to_json(data)
      Serializer.dump(data)
    end

    def headers(idempotency_key)
      if idempotency_key
        { 'Content-Type' => 'application/json', 'X-Request-ID' => idempotency_key }
      else
        { 'Content-Type' => 'application/json' }
      end
    end

    def logger
      config.logger
    end

    def raise_transport_error(response)
      logger.fatal "[#{response.status}] #{response.origin_body}" if logger
      error = CloudPay::HTTP_ERRORS[response.status] || CloudPay::ServerError
      raise error.new "[#{response.status}] #{response.origin_body}"
    end

    def build_connection
      Faraday::Connection.new(config.host, config.connection_options, &config.connection_block)
    end
  end
end
