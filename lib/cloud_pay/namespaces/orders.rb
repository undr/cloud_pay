# frozen_string_literal: true
module CloudPay
  class Orders < Namespace
    path_prefix '/orders'

    def create(attributes, options = {})
      run_if_valid(attributes, [:amount, :description], options) do |attributes|
        request(:create, attributes, options)
      end
    end

    def create!(attributes, options = {})
      result = create(attributes, options.merge(raise_error: true))
      result.model
    end

    def cancel(id, options = {})
      run_if_valid({ id: id }, options) do |attributes|
        request(:cancel, attributes, options)
      end
    end

    def cancel!(id, options = {})
      result = cancel(id, options.merge(raise_error: true))
      result.success?
    end
  end
end
