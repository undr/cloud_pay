# frozen_string_literal: true
module CloudPay
  class Subscriptions < Namespace
    path_prefix '/subscriptions'

    def get(id, options = {})
      run_if_valid({ id: id }, options) do |attributes|
        request(:get, attributes, options)
      end
    end

    def get!(id, options = {})
      result = get(id, options.merge(raise_error: true))
      result.model
    end

    def find(account_id, options = {})
      run_if_valid({ account_id: account_id }, options) do |attributes|
        request(:find, attributes, options)
      end
    end

    def find!(account_id, options = {})
      result = find(account_id, options.merge(raise_error: true))
      result.model
    end

    def create(attributes, options = {})
      run_if_valid(attributes, [
        :account_id,
        :description,
        :email,
        :amount,
        :currency,
        :require_confirmation,
        :start_date,
        :interval,
        :period
      ], options) do |attributes|
        request(:create, attributes, options)
      end
    end

    def create!(attributes, options = {})
      result = create(attributes, options.merge(raise_error: true))
      result.model
    end

    def update(id, attributes, options = {})
      run_if_valid(attributes.merge(id: id), [:id], options) do |attributes|
        request(:update, attributes, options)
      end
    end

    def update!(id, attributes, options = {})
      result = update(id, attributes, options.merge(raise_error: true))
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
