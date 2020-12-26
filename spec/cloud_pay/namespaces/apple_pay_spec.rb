# frozen_string_literal: true
require 'spec_helper'

RSpec.describe CloudPay::ApplePay do
  let(:apple_pay) { described_class.new(:test) }
  let(:attributes) { { validation_url: 'https://apple-pay-gateway.apple.com/paymentservices/startSession' } }

  describe '#start_session' do
    subject { apple_pay.start_session(attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('validation_url attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('apple_pay/start_session/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to be nil }
      its(:model) do
        is_expected.to eq(
          epoch_timestamp: 1545111111153,
          expires_at: 1545111111153,
          merchant_session_identifier: "SSH6FE83F9B853E00F7BD17260001DCF910",
          nonce: "d6358e06",
          merchant_identifier: "41B8000198128F7CC4295E03092BE5E287738FD77EC3238789846AC8EF73FCD8",
          domain_name: "demo.cloudpayments.ru",
          display_name: "demo.cloudpayments.ru",
          signature: "308006092a864886f70d010702a0803080020101310f300d060"
        )
      end
    end

    context 'failure' do
      before { stub_api_request('apple_pay/start_session/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('Some error maessge') }
      its(:model) { is_expected.to be nil }
    end

    context 'failure with server error' do
      before { stub_api_request('apple_pay/start_session/failed').to_return(status: 500) }

      it 'raises gateway error' do
        expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError)
      end
    end
  end

  describe '#start_session!' do
    subject { apple_pay.start_session!(attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }
      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('apple_pay/start_session/successful').perform }

      it do
        expect(subject).to eq(
          epoch_timestamp: 1545111111153,
          expires_at: 1545111111153,
          merchant_session_identifier: "SSH6FE83F9B853E00F7BD17260001DCF910",
          nonce: "d6358e06",
          merchant_identifier: "41B8000198128F7CC4295E03092BE5E287738FD77EC3238789846AC8EF73FCD8",
          domain_name: "demo.cloudpayments.ru",
          display_name: "demo.cloudpayments.ru",
          signature: "308006092a864886f70d010702a0803080020101310f300d060"
        )
      end
    end

    context 'failure' do
      before { stub_api_request('apple_pay/start_session/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, "Some error maessge") }
    end

    context 'failure with server error' do
      before { stub_api_request('apple_pay/start_session/failed').to_return(status: 500) }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end
end
