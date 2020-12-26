# frozen_string_literal: true
require 'spec_helper'

RSpec.describe CloudPay::Notifications do
  let(:notifications) { described_class.new(:test) }
  let(:attributes) do
    {
      is_enabled: true,
      address: 'http://example.com',
      http_method: 'GET',
      encoding: 'UTF8',
      format: 'CloudPayments'
    }
  end

  describe '#get' do
    subject { notifications.get('pay') }

    context 'success case' do
      before { stub_api_request('notifications/get/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to be nil }
      its(:model) do
        is_expected.to eq(
          is_enabled: true,
          address: 'http://example.com',
          http_method: 'GET',
          encoding: 'UTF8',
          format: 'CloudPayments'
        )
      end
    end

    context 'failure with server error' do
      before { stub_api_request('notifications/get/successful').to_return(status: 500, body: '') }

      it 'raises gateway error' do
        expect { subject.get('pay') }.to raise_error(CloudPay::HttpErrors::InternalServerError)
      end
    end
  end

  describe '#get!' do
    subject { notifications.get!('pay') }

    context 'success case' do
      before { stub_api_request('notifications/get/successful').perform }

      it do
        is_expected.to eq(
          is_enabled: true,
          address: 'http://example.com',
          http_method: 'GET',
          encoding: 'UTF8',
          format: 'CloudPayments'
        )
      end
    end

    context 'failure with server error' do
      before { stub_api_request('notifications/get/successful').to_return(status: 500, body: '') }

      it 'raises gateway error' do
        expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError)
      end
    end
  end

  describe '#update' do
    subject { notifications.update('pay', attributes) }

    context 'success case' do
      before { stub_api_request('notifications/update/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to be nil }
      its(:model) { is_expected.to be nil }
    end

    context 'failure' do
      before { stub_api_request('notifications/update/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to be nil }
      its(:model) { is_expected.to be nil }
    end

    context 'failure with server error' do
      before { stub_api_request('notifications/update/failed').to_return(status: 500, body: '') }

      it 'raises gateway error' do
        expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError)
      end
    end
  end

  describe '#update!' do
    subject { notifications.update!('pay', attributes) }

    context 'success case' do
      before { stub_api_request('notifications/update/successful').perform }

      it { is_expected.to be true }
    end

    context 'failure' do
      before { stub_api_request('notifications/update/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Unknown Gateway Error') }
    end

    context 'failure with server error' do
      before { stub_api_request('notifications/update/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end
end
