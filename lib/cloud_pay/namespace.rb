# frozen_string_literal: true
module CloudPay
  class Namespace
    class << self
      def path_prefix(value = nil)
        if value
          @path_prefix = value
        else
          @path_prefix ||= '/'
        end
      end
    end

    attr_reader :client

    def initialize(client = nil)
      @client = resolve_client(client)
    end

    def request(path, params, options = {})
      response = client.perform_request(resource_path(path, options), params, options)

      Result.new(response.body).tap do |result|
        raise_gateway_error(result) if !result.success? && options[:raise_error]
      end
    end

    def run_if_valid(attributes, *args, &block)
      options = args.last.is_a?(Hash) ? args.last : {}
      keys = args[0].is_a?(Array) ? args[0] : attributes.keys

      if invalid?(attributes, keys)
        fail CloudPay::ValidationError.new(keys) if options[:raise_error]
        return Result.new(success: false, message: "#{keys.join(', ')} attributes are required")
      end

      block.arity.zero? ? block.call : block.call(attributes)
    end

    private

    def invalid?(attributes, keys)
      keys.any? { |key| attributes[key].nil? }
    end

    def resource_path(path, options)
      path_prefix = options[:path_prefix] || self.class.path_prefix
      [path_prefix, path].compact.join('/').squeeze('/')
    end

    def raise_gateway_error(result)
      code = reason_code(result.model)
      exception = CloudPay::GATEWAY_ERRORS[code] || CloudPay::GatewayError

      fail exception.new(result.gateway_message, result.data) if code
      fail CloudPay::GatewayError.new(result.message, result.data)
    end

    def reason_code(model)
      model[:reason_code] if model
    end

    def resolve_client(client)
      case client
      when Symbol, Hash, CloudPay::Config, NilClass
        CloudPay::Client.new(client)
      when CloudPay::Client
        client
      else
        raise CloudPay::Error, 'Cannot resolve client'
      end
    end
  end
end
