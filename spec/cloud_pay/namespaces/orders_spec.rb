# frozen_string_literal: true
require 'spec_helper'

RSpec.describe CloudPay::Orders do
  let(:orders) { described_class.new(:test) }
  let(:attributes) do
    {
      amount: 10.0,
      currency: 'RUB',
      description: 'Payment at website example.com',
      email: 'client@test.local',
      require_confirmation: true,
      send_email: false
    }
  end

  describe '#create' do
    subject { orders.create(attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('amount, description attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('orders/create/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to be nil }
      its(:model) do
        is_expected.to eq(
          id: 'f2K8LV6reGE9WBFn',
          number: 61,
          amount: 10.0,
          currency: 'RUB',
          currency_code: 0,
          email: 'client@test.local',
          description: 'Payment at website example.com',
          require_confirmation: true,
          url: 'https://orders.cloudpayments.ru/d/f2K8LV6reGE9WBFn'
        )
      end
    end

    context 'failure' do
      before { stub_api_request('orders/create/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to be nil }
      its(:model) { is_expected.to be nil }
    end

    context 'failure with server error' do
      before { stub_api_request('orders/create/failed').to_return(status: 500, body: '') }

      it 'raises gateway error' do
        expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError)
      end
    end
  end

  describe '#create!' do
    subject { orders.create!(attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('orders/create/successful').perform }

      it do
        is_expected.to eq(
          id: 'f2K8LV6reGE9WBFn',
          number: 61,
          amount: 10.0,
          currency: 'RUB',
          currency_code: 0,
          email: 'client@test.local',
          description: 'Payment at website example.com',
          require_confirmation: true,
          url: 'https://orders.cloudpayments.ru/d/f2K8LV6reGE9WBFn'
        )
      end
    end

    context 'failure' do
      before { stub_api_request('orders/create/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Unknown Gateway Error') }
    end

    context 'failure with server error' do
      before { stub_api_request('orders/create/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#cancel' do
    let(:id) { 'f2K8LV6reGE9WBFn' }

    subject { orders.cancel(id) }

    context 'without required attributes' do
      let(:id) { nil }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('id attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('orders/cancel/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to be nil}
      its(:model) { is_expected.to be nil }
    end

    context 'failure' do
      before { stub_api_request('orders/cancel/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to be nil}
      its(:model) { is_expected.to be nil }
    end

    context 'failure with server error' do
      before { stub_api_request('orders/cancel/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#cancel!' do
    let(:id) { 'f2K8LV6reGE9WBFn' }

    subject { orders.cancel!(id) }

    context 'without required attributes' do
      let(:id) { nil }

      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('orders/cancel/successful').perform }

      it { expect(subject).to be true }
    end

    context 'failure' do
      before { stub_api_request('orders/cancel/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Unknown Gateway Error') }
    end

    context 'failure with server error' do
      before { stub_api_request('orders/cancel/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end
end
