# frozen_string_literal: true
require 'spec_helper'

RSpec.describe CloudPay::Kassir::State do
  subject(:state) { described_class.new(:test) }

  describe '#update' do
    let(:attributes) do
      {
         inn: '7708806062',
         device_number: '00000000000000000001',
         fiscal_number: '9999078900005430',
         on_maintenance: true
      }
    end

    subject { state.update(attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('inn, device_number, fiscal_number, on_maintenance attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('kassir/state/update/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to eq('Kkt status was changed') }
      its(:model) { is_expected.to be nil }
    end

    context 'failure' do
      before { stub_api_request('kassir/state/update/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('Error message') }
      its(:model) { is_expected.to be nil }
    end

    context 'failure with server error' do
      before { stub_api_request('kassir/state/update/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#update!' do
    let(:attributes) do
      {
         inn: '7708806062',
         device_number: '00000000000000000001',
         fiscal_number: '9999078900005430',
         on_maintenance: true
      }
    end

    subject { state.update!(attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('kassir/state/update/successful').perform }

      it { is_expected.to be true }
    end

    context 'failure' do
      before { stub_api_request('kassir/state/update/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Error message') }
    end

    context 'failure with server error' do
      before { stub_api_request('kassir/state/update/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#get' do
    let(:attributes) { { device_number: '00000000000000000001', fiscal_number: '9999078900005430' } }

    subject { state.get(attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('device_number, fiscal_number attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('kassir/state/get/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to be nil }
      its(:model) do
        is_expected.to eq(
          inn: '7708806062',
          device_number: '00000000000000000001',
          fiscal_number: '9999078900005430',
          reg_number: '0000000004030311',
          status: 'Online',
          fiscal: true,
          ofd_name: 'Первый ОФД',
          settle_place: '117342, Москва, ул. Бутлерова, 17Б',
          calculation_place: 'www.my.ru',
          kkm_model_name: 'Терминал ФА',
          fiscal_date_end: '2021-01-01T00:00:00.000+000',
          firmware_version: '14.1.2',
          is_bso: false
        )
      end
    end

    context 'failure' do
      before { stub_api_request('kassir/state/get/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('Error message') }
      its(:model) { is_expected.to be nil }
    end

    context 'failure with server error' do
      before { stub_api_request('kassir/state/get/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#get!' do
    let(:attributes) { { device_number: '00000000000000000001', fiscal_number: '9999078900005430' } }

    subject { state.get!(attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('kassir/state/get/successful').perform }

      it do
        is_expected.to eq(
          inn: '7708806062',
          device_number: '00000000000000000001',
          fiscal_number: '9999078900005430',
          reg_number: '0000000004030311',
          status: 'Online',
          fiscal: true,
          ofd_name: 'Первый ОФД',
          settle_place: '117342, Москва, ул. Бутлерова, 17Б',
          calculation_place: 'www.my.ru',
          kkm_model_name: 'Терминал ФА',
          fiscal_date_end: '2021-01-01T00:00:00.000+000',
          firmware_version: '14.1.2',
          is_bso: false
        )
      end
    end

    context 'failure' do
      before { stub_api_request('kassir/state/get/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Error message') }
    end

    context 'failure with server error' do
      before { stub_api_request('kassir/state/get/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end
end
