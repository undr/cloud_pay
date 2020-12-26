# frozen_string_literal: true
require 'openssl'
require 'base64'

module CloudPay
  class Webhooks
    attr_reader :config

    HOOKS = [:check, :pay, :fail, :recurrent, :cancel, :confirm, :refund, :receipt].freeze

    def initialize(config)
      @config = CloudPay.config(config)
      @digest = OpenSSL::Digest.new('sha256')
    end

    def data_valid?(data, hmac)
      Base64.decode64(hmac) == OpenSSL::HMAC.digest(digest, config.secret_key, data)
    end

    def validate_data!(data, hmac)
      raise HMACError unless data_valid?(data, hmac)
    end

    def event(data)
      KeyConverter.from_api(data)
    end

    private

    attr_reader :digest
  end
end
