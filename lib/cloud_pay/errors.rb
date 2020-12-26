# frozen_string_literal: true
module CloudPay
  class ErrorUtils
    class << self
      def get_exception_class(name)
        if GatewayErrors.const_defined?(name)
          GatewayErrors.const_get(name)
        else
          GatewayErrors.const_set(name, Class.new(ReasonedGatewayError))
        end
      end
    end
  end

  class Error < StandardError; end
  class HMACError < Error; end
  class ServerError < Error; end
  class GatewayError < Error
    attr_reader :body

    def initialize(message, body)
      super(message || 'Unknown Gateway Error')
      @body = body
    end
  end

  class ReasonedGatewayError < GatewayError; end
  class ValidationError < Error
    attr_reader :keys

    def initialize(keys)
      super("#{keys.join(', ')} attributes are required")
      @keys = keys
    end
  end

  module HttpErrors; end
  module GatewayErrors; end

  HTTP_STATUSES = {
    300 => 'MultipleChoices',
    301 => 'MovedPermanently',
    302 => 'Found',
    303 => 'SeeOther',
    304 => 'NotModified',
    305 => 'UseProxy',
    307 => 'TemporaryRedirect',
    308 => 'PermanentRedirect',

    400 => 'BadRequest',
    401 => 'Unauthorized',
    402 => 'PaymentRequired',
    403 => 'Forbidden',
    404 => 'NotFound',
    405 => 'MethodNotAllowed',
    406 => 'NotAcceptable',
    407 => 'ProxyAuthenticationRequired',
    408 => 'RequestTimeout',
    409 => 'Conflict',
    410 => 'Gone',
    411 => 'LengthRequired',
    412 => 'PreconditionFailed',
    413 => 'RequestEntityTooLarge',
    414 => 'RequestURITooLong',
    415 => 'UnsupportedMediaType',
    416 => 'RequestedRangeNotSatisfiable',
    417 => 'ExpectationFailed',
    418 => 'ImATeapot',
    421 => 'TooManyConnectionsFromThisIP',
    426 => 'UpgradeRequired',
    450 => 'BlockedByWindowsParentalControls',
    494 => 'RequestHeaderTooLarge',
    497 => 'HTTPToHTTPS',
    499 => 'ClientClosedRequest',

    500 => 'InternalServerError',
    501 => 'NotImplemented',
    502 => 'BadGateway',
    503 => 'ServiceUnavailable',
    504 => 'GatewayTimeout',
    505 => 'HTTPVersionNotSupported',
    506 => 'VariantAlsoNegotiates',
    510 => 'NotExtended'
  }

  REASON_CODES = {
    5001 => 'ReferToCardIssuer',
    5003 => 'InvalidMerchant',
    5004 => 'PickUpCard',
    5005 => 'DoNotHonor',
    5006 => 'Error',
    5007 => 'PickUpCardSpecialConditions',
    5012 => 'InvalidTransaction',
    5013 => 'AmountError',
    5014 => 'InvalidCardNumber',
    5015 => 'NoSuchIssuer',
    5019 => 'TransactionError',
    5030 => 'FormatError',
    5031 => 'BankNotSupportedBySwitch',
    5033 => 'ExpiredCardPickup',
    5034 => 'SuspectedFraud',
    5036 => 'RestrictedCard',
    5041 => 'LostCard',
    5043 => 'StolenCard',
    5051 => 'InsufficientFunds',
    5054 => 'ExpiredCard',
    5057 => 'TransactionNotPermitted',
    5062 => 'RestrictedCard',
    5063 => 'SecurityViolation',
    5065 => 'ExceedWithdrawalFrequency'	,
    5082 => 'IncorrectCVV',
    5091 => 'Timeout',
    5092 => 'CannotReachNetwork',
    5096 => 'SystemError',
    5204 => 'UnableToProcess',
    5206 => 'AuthenticationFailed',
    5207 => 'AuthenticationUnavailable',
    5300 => 'AntiFraud'
  }

  HTTP_ERRORS = HTTP_STATUSES.inject({}) do |result, error|
    status, name = error
    result[status] = HttpErrors.const_set(name, Class.new(ServerError))
    result
  end

  GATEWAY_ERRORS = REASON_CODES.inject({}) do |result, error|
    code, name = error
    result[code] = ErrorUtils.get_exception_class(name)
    result
  end
end
