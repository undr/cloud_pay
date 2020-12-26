# frozen_string_literal: true
module CloudPay
  class Client
    class KeyConverter
      class << self
        def from_api(attributes)
          convert(:underscore, attributes)
        end

        def to_api(attributes)
          convert(:camelize, attributes)
        end

        private

        def process_value(method_name, value)
          case value
          when Hash
            convert(method_name, value)
          when Array
            value.map { |item| convert(method_name, item) }
          else
            value
          end
        end

        def convert(method_name, attributes)
          if attributes.is_a?(Hash)
            attributes.reduce({}) do |memo, (key, value)|
              memo.merge(send(method_name, key) => process_value(method_name, value))
            end
          else
            attributes
          end
        end

        def underscore(key)
          key.
            to_s.
            gsub(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2').
            gsub(/([a-z\d])([A-Z])/, '\1_\2').
            tr('-', '_').
            downcase.
            to_sym
        end

        def camelize(key)
          key.
            to_s.
            gsub(/^[a-z\d]*/) { $&.capitalize }.
            gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }.
            gsub('/', '::')
        end
      end
    end
  end
end
