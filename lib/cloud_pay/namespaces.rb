# frozen_string_literal: true
require 'cloud_pay/namespaces/payments'
require 'cloud_pay/namespaces/payments/main'
require 'cloud_pay/namespaces/payments/cards'
require 'cloud_pay/namespaces/payments/tokens'
require 'cloud_pay/namespaces/kassir'
require 'cloud_pay/namespaces/kassir/main'
require 'cloud_pay/namespaces/kassir/state'
require 'cloud_pay/namespaces/kassir/receipt'
require 'cloud_pay/namespaces/apple_pay'
require 'cloud_pay/namespaces/subscriptions'
require 'cloud_pay/namespaces/notifications'
require 'cloud_pay/namespaces/orders'

module CloudPay
  module Namespaces
    def payments
      Payments.new(self)
    end

    def notifications
      Notifications.new(self)
    end

    def subscriptions
      Subscriptions.new(self)
    end

    def orders
      Orders.new(self)
    end

    def kassir
      Kassir.new(self)
    end

    def apple_pay
      ApplePay.new(self)
    end

    def ping
      response = perform_request('/test', nil).body || {}
      !!response[:success]
    rescue ::Faraday::ConnectionFailed, ::Faraday::TimeoutError, CloudPay::ServerError => e
      false
    end
  end
end
