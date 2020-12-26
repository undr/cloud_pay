# frozen_string_literal: true
module CloudPay
  class Notifications < Namespace
    path_prefix '/site/notifications'

    def get(type, options = {})
      request("#{type}/get", nil, options)
    end

    def get!(type, _options = {})
      result = get(type, raise_error: true)
      result.model
    end

    def update(type, attributes, options = {})
      request("#{type}/update", attributes, options)
    end

    def update!(type, attributes, _options = {})
      result = update(type, attributes, raise_error: true)
      result.success?
    end
  end
end
