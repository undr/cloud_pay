# frozen_string_literal: true
require 'spec_helper'

RSpec.describe CloudPay::Kassir::Main do
  subject(:kassir) { described_class.new(:test) }

  its(:receipt) { is_expected.to be_instance_of(CloudPay::Kassir::Receipt) }
  its(:state) { is_expected.to be_instance_of(CloudPay::Kassir::State) }

  describe '#fiscalize' do
    let(:attributes) do
      {
        inn: '7708806062',
        device_number: '00000000000000000001',
        fiscal_number: '9999078900005430',
        reg_number: '0000000004030311',
        url: 'www.cloudpayments.ru',
        ofd: 'PeterService',
        taxation_system: [0],
        merchant_email: 'my@mail.ru',
        merchant_phone: '899999999',
        is_bso: false
      }
    end

    subject { kassir.fiscalize(attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('inn, device_number, fiscal_number, reg_number, url, ofd, taxation_system, merchant_email attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('kassir/fiscalize/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to eq('Fiscal data queued') }
      its(:model) { is_expected.to be nil }
    end

    context 'failure' do
      before { stub_api_request('kassir/fiscalize/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('Error message') }
      its(:model) { is_expected.to be nil }
    end

    context 'failure with server error' do
      before { stub_api_request('kassir/fiscalize/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#fiscalize!' do
    let(:attributes) do
      {
        inn: '7708806062',
        device_number: '00000000000000000001',
        fiscal_number: '9999078900005430',
        reg_number: '0000000004030311',
        url: 'www.cloudpayments.ru',
        ofd: 'PeterService',
        taxation_system: [0],
        merchant_email: 'my@mail.ru',
        merchant_phone: '899999999',
        is_bso: false
      }
    end

    subject { kassir.fiscalize!(attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('kassir/fiscalize/successful').perform }
      it { is_expected.to be true }
    end

    context 'failure' do
      before { stub_api_request('kassir/fiscalize/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Error message') }
    end

    context 'failure with server error' do
      before { stub_api_request('kassir/fiscalize/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end
end
