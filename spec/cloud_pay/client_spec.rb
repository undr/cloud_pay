# frozen_string_literal: true
require 'spec_helper'

RSpec.describe CloudPay::Client do
  subject { described_class.new(:test) }

  its(:payments) { is_expected.to be_instance_of(CloudPay::Payments::Main) }
  its(:notifications) { is_expected.to be_instance_of(CloudPay::Notifications) }
  its(:subscriptions) { is_expected.to be_instance_of(CloudPay::Subscriptions) }
  its(:orders) { is_expected.to be_instance_of(CloudPay::Orders) }
  its(:kassir) { is_expected.to be_instance_of(CloudPay::Kassir::Main) }

  describe '#ping' do
    subject { described_class.new(:test).ping }

    context 'when successful response' do
      before { stub_api_request('ping/successful').perform }

      it { is_expected.to be_truthy }
    end

    context 'when failed response' do
      before { stub_api_request('ping/failed').perform }

      it { is_expected.to be_falsy }
    end

    context 'when empty response' do
      before { stub_api_request('ping/failed').to_return(body: '') }

      it { is_expected.to be_falsy }
    end

    context 'when error response' do
      before { stub_api_request('ping/failed').to_return(status: 404) }

      it { is_expected.to be_falsy }
    end

    context 'when exception occurs while request' do
      before { stub_api_request('ping/failed').to_raise(::Faraday::ConnectionFailed) }

      it { is_expected.to be_falsy }
    end

    context 'when timeout occurs while request' do
      before { stub_api_request('ping/failed').to_timeout }

      it { is_expected.to be_falsy }
    end
  end
end
