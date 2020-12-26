# frozen_string_literal: true
require 'date'
require 'json'
require 'faraday'
require 'forwardable'
require 'cloud_pay/version'
require 'cloud_pay/errors'
require 'cloud_pay/config'
require 'cloud_pay/config/repo'
require 'cloud_pay/namespace'
require 'cloud_pay/namespaces'
require 'cloud_pay/result'
require 'cloud_pay/webhooks'
require 'cloud_pay/client'

module CloudPay
  extend self
  extend Forwardable

  attr_writer :config_repo

  def_delegators :config_repo, :configure, :with_config, :config
  def_delegator :config_repo, :default, :default_config_name

  def client(name = nil)
    name ||= default_config_name
    CloudPay::Client.new(name)
  end

  def config_repo
    @config_repo ||= CloudPay::Config::Repo.new
  end

  def retryable_errors
    @retryable_errors ||= default_retryable_errors
  end

  def set_retryable_errors(errors)
    @retryable_errors = errors
  end

  def default_retryable_errors
    [
      CloudPay::GatewayErrors::FormatError,
      CloudPay::GatewayErrors::InsufficientFunds,
      CloudPay::GatewayErrors::Timeout,
      CloudPay::GatewayErrors::CannotReachNetwork,
      CloudPay::GatewayErrors::SystemError
    ]
  end
end
