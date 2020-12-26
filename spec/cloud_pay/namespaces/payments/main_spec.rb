# frozen_string_literal: true
require 'spec_helper'

RSpec.describe CloudPay::Payments::Main do
  subject(:payments) { described_class.new(:test) }

  its(:cards) { is_expected.to be_instance_of(CloudPay::Payments::Cards) }
  its(:tokens) { is_expected.to be_instance_of(CloudPay::Payments::Tokens) }

  describe '#confirm' do
    let(:id) { 585020480 }
    let(:attributes) { { amount: 120 } }

    subject { payments.confirm(id, attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('transaction_id, amount attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('payments/confirm/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to be nil }
      its(:model) { is_expected.to be nil }
    end

    context 'failure' do
      before { stub_api_request('payments/confirm/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('Error message') }
      its(:model) { is_expected.to be nil }
    end

    context 'failure with server error' do
      before { stub_api_request('payments/confirm/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#confirm!' do
    let(:id) { 585020480 }
    let(:attributes) { { amount: 120 } }

    subject { payments.confirm!(id, attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('payments/confirm/successful').perform }

      it { is_expected.to be true }
    end

    context 'failure' do
      before { stub_api_request('payments/confirm/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Error message') }
    end

    context 'failure with server error' do
      before { stub_api_request('payments/confirm/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#void' do
    let(:id) { 585020480 }

    subject { payments.void(id) }

    context 'without required attributes' do
      let(:id) { nil }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('transaction_id attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('payments/void/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to be nil }
      its(:model) { is_expected.to be nil }
    end

    context 'failure' do
      before { stub_api_request('payments/void/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('Error message') }
      its(:model) { is_expected.to be nil }
    end

    context 'failure with server error' do
      before { stub_api_request('payments/void/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#void!' do
    let(:id) { 585020480 }

    subject { payments.void!(id) }

    context 'without required attributes' do
      let(:id) { nil }

      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('payments/void/successful').perform }

      it { is_expected.to be true }
    end

    context 'failure' do
      before { stub_api_request('payments/void/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Error message') }
    end

    context 'failure with server error' do
      before { stub_api_request('payments/void/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#refund' do
    let(:id) { 585020480 }
    let(:attributes) { { amount: 120 } }

    subject { payments.refund(id, attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('transaction_id, amount attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('payments/refund/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to be nil }
      its(:model) { is_expected.to eq(transaction_id: 568) }
    end

    context 'failure' do
      before { stub_api_request('payments/refund/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('Error message') }
      its(:model) { is_expected.to be nil }
    end

    context 'failure with server error' do
      before { stub_api_request('payments/refund/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#refund!' do
    let(:id) { 585020480 }
    let(:attributes) { { amount: 120 } }

    subject { payments.refund!(id, attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('payments/refund/successful').perform }

      it { is_expected.to eq(transaction_id: 568) }
    end

    context 'failure' do
      before { stub_api_request('payments/refund/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Error message') }
    end

    context 'failure with server error' do
      before { stub_api_request('payments/refund/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#get' do
    let(:id) { 585020480 }

    subject { payments.get(id) }

    context 'without required attributes' do
      let(:id) { nil }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('transaction_id attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('payments/get/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to eq('Payment successful') }
      its(:model) do
        is_expected.to eq(
          transaction_id: 585020480,
          amount: 10.0,
          currency: 'RUB',
          currency_code: 0,
          invoice_id: '1234567',
          account_id: 'user_x',
          email: nil,
          description: 'Payment for goods on example.com',
          json_data: nil,
          created_date: '/Date(1401718880000)/',
          created_date_iso: '2014-08-09T11:49:41',
          auth_date: '/Date(1401733880523)/',
          auth_date_iso: "2014-08-09T11:49:42",
          confirm_date: '/Date(1401733880523)/',
          confirm_date_iso: "2014-08-09T11:49:42",
          auth_code: '123456',
          test_mode: true,
          ip_address: '195.91.194.13',
          ip_country: 'RU',
          ip_city: 'Ufa',
          ip_region: 'Bashkortostan Republic',
          ip_district: 'Volga Federal District',
          ip_latitude: 54.7355,
          ip_longitude: 55.991982,
          card_first_six: '411111',
          card_last_four: '1111',
          card_type: 'Visa',
          card_type_code: 0,
          issuer_bank_country: 'RU',
          status: 'Completed',
          status_code: 3,
          reason: 'Approved',
          reason_code: 0,
          card_holder_message: 'Payment successful',
          name: 'CARDHOLDER NAME',
          token: 'a4e67841-abb0-42de-a364-d1d8f9f4b3c0'
        )
      end
    end

    context 'failure' do
      before { stub_api_request('payments/get/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('Not found') }
      its(:model) { is_expected.to be nil }
    end

    context 'failure with server error' do
      before { stub_api_request('payments/get/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#get!' do
    let(:id) { 585020480 }

    subject { payments.get!(id) }

    context 'without required attributes' do
      let(:id) { nil }

      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('payments/get/successful').perform }

      it do
        is_expected.to eq(
          transaction_id: 585020480,
          amount: 10.0,
          currency: 'RUB',
          currency_code: 0,
          invoice_id: '1234567',
          account_id: 'user_x',
          email: nil,
          description: 'Payment for goods on example.com',
          json_data: nil,
          created_date: '/Date(1401718880000)/',
          created_date_iso: '2014-08-09T11:49:41',
          auth_date: '/Date(1401733880523)/',
          auth_date_iso: "2014-08-09T11:49:42",
          confirm_date: '/Date(1401733880523)/',
          confirm_date_iso: "2014-08-09T11:49:42",
          auth_code: '123456',
          test_mode: true,
          ip_address: '195.91.194.13',
          ip_country: 'RU',
          ip_city: 'Ufa',
          ip_region: 'Bashkortostan Republic',
          ip_district: 'Volga Federal District',
          ip_latitude: 54.7355,
          ip_longitude: 55.991982,
          card_first_six: '411111',
          card_last_four: '1111',
          card_type: 'Visa',
          card_type_code: 0,
          issuer_bank_country: 'RU',
          status: 'Completed',
          status_code: 3,
          reason: 'Approved',
          reason_code: 0,
          card_holder_message: 'Payment successful',
          name: 'CARDHOLDER NAME',
          token: 'a4e67841-abb0-42de-a364-d1d8f9f4b3c0'
        )
      end
    end

    context 'failure' do
      before { stub_api_request('payments/get/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Not found') }
    end

    context 'failure with server error' do
      before { stub_api_request('payments/get/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#find' do
    let(:id) { 585020480 }

    subject { payments.find(id) }

    context 'without required attributes' do
      let(:id) { nil }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('invoice_id attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('payments/find/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to eq('Payment successful') }
      its(:model) do
        is_expected.to eq(
          transaction_id: 585020480,
          amount: 10.0,
          currency: 'RUB',
          currency_code: 0,
          invoice_id: '1234567',
          account_id: 'user_x',
          email: nil,
          description: 'Payment for goods on example.com',
          json_data: nil,
          created_date: '/Date(1401718880000)/',
          created_date_iso: '2014-08-09T11:49:41',
          auth_date: '/Date(1401733880523)/',
          auth_date_iso: "2014-08-09T11:49:42",
          confirm_date: '/Date(1401733880523)/',
          confirm_date_iso: "2014-08-09T11:49:42",
          auth_code: '123456',
          test_mode: true,
          ip_address: '195.91.194.13',
          ip_country: 'RU',
          ip_city: 'Ufa',
          ip_region: 'Bashkortostan Republic',
          ip_district: 'Volga Federal District',
          ip_latitude: 54.7355,
          ip_longitude: 55.991982,
          card_first_six: '411111',
          card_last_four: '1111',
          card_type: 'Visa',
          card_type_code: 0,
          issuer_bank_country: 'RU',
          status: 'Completed',
          status_code: 3,
          reason: 'Approved',
          reason_code: 0,
          card_holder_message: 'Payment successful',
          name: 'CARDHOLDER NAME',
          token: 'a4e67841-abb0-42de-a364-d1d8f9f4b3c0'
        )
      end
    end

    context 'failure' do
      before { stub_api_request('payments/find/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('Not found') }
      its(:model) { is_expected.to be nil }
    end

    context 'failure with server error' do
      before { stub_api_request('payments/find/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#find!' do
    let(:id) { 585020480 }

    subject { payments.find!(id) }

    context 'without required attributes' do
      let(:id) { nil }

      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('payments/find/successful').perform }

      it do
        is_expected.to eq(
          transaction_id: 585020480,
          amount: 10.0,
          currency: 'RUB',
          currency_code: 0,
          invoice_id: '1234567',
          account_id: 'user_x',
          email: nil,
          description: 'Payment for goods on example.com',
          json_data: nil,
          created_date: '/Date(1401718880000)/',
          created_date_iso: '2014-08-09T11:49:41',
          auth_date: '/Date(1401733880523)/',
          auth_date_iso: "2014-08-09T11:49:42",
          confirm_date: '/Date(1401733880523)/',
          confirm_date_iso: "2014-08-09T11:49:42",
          auth_code: '123456',
          test_mode: true,
          ip_address: '195.91.194.13',
          ip_country: 'RU',
          ip_city: 'Ufa',
          ip_region: 'Bashkortostan Republic',
          ip_district: 'Volga Federal District',
          ip_latitude: 54.7355,
          ip_longitude: 55.991982,
          card_first_six: '411111',
          card_last_four: '1111',
          card_type: 'Visa',
          card_type_code: 0,
          issuer_bank_country: 'RU',
          status: 'Completed',
          status_code: 3,
          reason: 'Approved',
          reason_code: 0,
          card_holder_message: 'Payment successful',
          name: 'CARDHOLDER NAME',
          token: 'a4e67841-abb0-42de-a364-d1d8f9f4b3c0'
        )
      end
    end

    context 'failure' do
      before { stub_api_request('payments/find/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Not found') }
    end

    context 'failure with server error' do
      before { stub_api_request('payments/find/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#list' do
    let(:attributes) { { date: '2019-02-21', time_zone: 'MSK'} }

    subject { payments.list(attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('date attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('payments/list/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to be nil }
      its(:model) do
        is_expected.to eq([
          transaction_id: 585020480,
          amount: 10.0,
          currency: 'RUB',
          currency_code: 0,
          invoice_id: '1234567',
          account_id: 'user_x',
          email: nil,
          description: 'Payment for goods on example.com',
          json_data: nil,
          created_date: '/Date(1401718880000)/',
          created_date_iso: '2014-08-09T11:49:41',
          auth_date: '/Date(1401733880523)/',
          auth_date_iso: "2014-08-09T11:49:42",
          confirm_date: '/Date(1401733880523)/',
          confirm_date_iso: "2014-08-09T11:49:42",
          auth_code: '123456',
          test_mode: true,
          ip_address: '195.91.194.13',
          ip_country: 'RU',
          ip_city: 'Ufa',
          ip_region: 'Bashkortostan Republic',
          ip_district: 'Volga Federal District',
          ip_latitude: 54.7355,
          ip_longitude: 55.991982,
          card_first_six: '411111',
          card_last_four: '1111',
          card_type: 'Visa',
          card_type_code: 0,
          issuer_bank_country: 'RU',
          status: 'Completed',
          status_code: 3,
          reason: 'Approved',
          reason_code: 0,
          card_holder_message: 'Payment successful',
          name: 'CARDHOLDER NAME',
          token: 'a4e67841-abb0-42de-a364-d1d8f9f4b3c0'
        ])
      end
    end

    context 'failure' do
      before { stub_api_request('payments/list/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('Not found') }
      its(:model) { is_expected.to be nil }
    end

    context 'failure with server error' do
      before { stub_api_request('payments/list/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#list!' do
    let(:attributes) { { date: '2019-02-21', time_zone: 'MSK'} }

    subject { payments.list!(attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('payments/list/successful').perform }

      it do
        is_expected.to eq([
          transaction_id: 585020480,
          amount: 10.0,
          currency: 'RUB',
          currency_code: 0,
          invoice_id: '1234567',
          account_id: 'user_x',
          email: nil,
          description: 'Payment for goods on example.com',
          json_data: nil,
          created_date: '/Date(1401718880000)/',
          created_date_iso: '2014-08-09T11:49:41',
          auth_date: '/Date(1401733880523)/',
          auth_date_iso: "2014-08-09T11:49:42",
          confirm_date: '/Date(1401733880523)/',
          confirm_date_iso: "2014-08-09T11:49:42",
          auth_code: '123456',
          test_mode: true,
          ip_address: '195.91.194.13',
          ip_country: 'RU',
          ip_city: 'Ufa',
          ip_region: 'Bashkortostan Republic',
          ip_district: 'Volga Federal District',
          ip_latitude: 54.7355,
          ip_longitude: 55.991982,
          card_first_six: '411111',
          card_last_four: '1111',
          card_type: 'Visa',
          card_type_code: 0,
          issuer_bank_country: 'RU',
          status: 'Completed',
          status_code: 3,
          reason: 'Approved',
          reason_code: 0,
          card_holder_message: 'Payment successful',
          name: 'CARDHOLDER NAME',
          token: 'a4e67841-abb0-42de-a364-d1d8f9f4b3c0'
        ])
      end
    end

    context 'failure' do
      before { stub_api_request('payments/list/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Not found') }
    end

    context 'failure with server error' do
      before { stub_api_request('payments/list/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end
end
