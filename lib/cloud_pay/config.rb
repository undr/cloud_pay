# frozen_string_literal: true
module CloudPay
  class Config
    OPTIONS = [
      :host,
      :public_key,
      :secret_key,
      :connection_options,
      :logger,
      :log
    ].freeze

    DEFAULT_LOGGER = -> {
      require 'logger'
      logger = Logger.new(STDERR)
      logger.progname = 'cloud_pay'
      logger.formatter = -> (severity, datetime, progname, msg) { "#{datetime} (#{progname}): #{msg}\n" }
      logger
    }

    attr_accessor *OPTIONS
    attr_writer :logger

    def initialize(options = {})
      @log = false
      @connection_options = {}
      @connection_block = nil
      @host = 'https://api.cloudpayments.ru'

      assign_options(options) if options
    end

    def logger
      @logger ||= log ? DEFAULT_LOGGER.call : nil
    end

    def connection_block(&block)
      if block_given?
        @connection_block = block
      else
        @connection_block
      end
    end

    def merge(options)
      OPTIONS.reduce(dup) do |memo, var|
        memo.send(:"#{var}=", options[var]) if options.key?(var)
        memo
      end
    end

    def dup
      clone = super
      clone.connection_options = connection_options.dup
      clone
    end

    private

    def assign_options(options)
      OPTIONS.each do |var|
        self.send(:"#{var}=", options[var]) if options.key?(var)
      end
    end
  end
end
