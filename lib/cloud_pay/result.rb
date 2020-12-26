module CloudPay
  class Result
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def success?
      !!data[:success]
    end

    def model
      data[:model]
    end

    def message
      data[:message]
    end

    def error_message
      message || gateway_message
    end

    def gateway_message
      model[:card_holder_message] if model.is_a?(Hash)
    end
  end
end
