# frozen_string_literal: true
module CloudPay
  class Client
    class Serializer
      class << self
        def load(data)
          return nil if data.empty?

          data = JSON.load(data)
          KeyConverter.from_api(data)
        end

        def dump(data)
          return '' if data.nil?

          data = KeyConverter.to_api(data)
          JSON.dump(data)
        end
      end
    end
  end
end
