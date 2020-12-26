# frozen_string_literal: true
require 'spec_helper'

RSpec.describe CloudPay::Kassir::Receipt do
  subject(:receipt) { described_class.new(:test) }

  describe '#create' do
    let(:attributes) do
      {
        inn: '7708806062',
        invoice_id: '1234567',
        account_id: 'user@example.com',
        type: 'Income',
        customer_receipt: {
          items: [{
            label: 'Наименование товара 1',
            price: 100.00,
            quantity: 1.00,
            amount: 100.00,
            vat: 0,
            method: 0,
            object: 0,
            measurement_unit: 'шт'
          }],
          calculation_place: 'www.my.ru',
          taxation_system: 0,
          email: 'user@example.com',
          phone: '',
          customer_info: '',
          customer_inn: '7708806063',
          is_bso: false,
          agent_sign: nil,
          amounts: {
            electronic: 1300.00,
            advance_payment: 0.00,
            credit: 0.00,
            provision: 0.00
          }
        }
      }
    end

    subject { receipt.create(attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('inn, type, customer_receipt attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('kassir/receipt/create/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to eq('Queued') }
      its(:model) { is_expected.to eq(id: 'QSnuAqV', error_code: 0) }
    end

    context 'failure' do
      before { stub_api_request('kassir/receipt/create/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('Компания с ИНН 7777777777 не найдена') }
      its(:model) { is_expected.to eq(error_code: -1) }
    end

    context 'failure with server error' do
      before { stub_api_request('kassir/receipt/create/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#create!' do
    let(:attributes) do
      {
        inn: '7708806062',
        invoice_id: '1234567',
        account_id: 'user@example.com',
        type: 'Income',
        customer_receipt: {
          items: [{
            label: 'Наименование товара 1',
            price: 100.00,
            quantity: 1.00,
            amount: 100.00,
            vat: 0,
            method: 0,
            object: 0,
            measurement_unit: 'шт'
          }],
          calculation_place: 'www.my.ru',
          taxation_system: 0,
          email: 'user@example.com',
          phone: '',
          customer_info: '',
          customer_inn: '7708806063',
          is_bso: false,
          agent_sign: nil,
          amounts: {
            electronic: 1300.00,
            advance_payment: 0.00,
            credit: 0.00,
            provision: 0.00
          }
        }
      }
    end

    subject { receipt.create!(attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('kassir/receipt/create/successful').perform }

      it { is_expected.to eq(id: 'QSnuAqV', error_code: 0) }
    end

    context 'failure' do
      before { stub_api_request('kassir/receipt/create/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Компания с ИНН 7777777777 не найдена') }
    end

    context 'failure with server error' do
      before { stub_api_request('kassir/receipt/create/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#status' do
    let(:id) { 'Nr9eTaj' }

    subject { receipt.status(id) }

    context 'without required attributes' do
      let(:id) { nil }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('id attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('kassir/receipt/status/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to be nil }
      its(:model) { is_expected.to eq('Processed') }
    end

    context 'failure' do
      before { stub_api_request('kassir/receipt/status/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('Error message') }
      its(:model) { is_expected.to be nil }
    end

    context 'failure with server error' do
      before { stub_api_request('kassir/receipt/status/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#status!' do
    let(:id) { 'Nr9eTaj' }

    subject { receipt.status!(id) }

    context 'without required attributes' do
      let(:id) { nil }

      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('kassir/receipt/status/successful').perform }

      it { is_expected.to eq('Processed') }
    end

    context 'failure' do
      before { stub_api_request('kassir/receipt/status/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Error message') }
    end

    context 'failure with server error' do
      before { stub_api_request('kassir/receipt/status/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#get' do
    let(:id) { 'Nr9eTaj' }

    subject { receipt.get(id) }

    context 'without required attributes' do
      let(:id) { nil }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('id attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('kassir/receipt/get/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to be nil }
      its(:model) do
        is_expected.to eq(
          email: 'user@example.com',
          phone: nil,
          items: [{
            label: 'Product №1',
            price: 100,
            quantity: 1,
            amount: 100,
            department: nil,
            vat: 0,
            ean13: nil,
            agent_sign: nil,
            method: 6,
            object: 3,
            measurement_unit: 'шт',
            code: '1322',
            agent_data: nil,
            purveyor_data: nil
          }],
          taxation_system: 2,
          amounts: nil,
          is_bso: false,
          additional_data: {
            id: 'Nr9eTaj',
            account_id: 'user@example.com',
            amount: 1150,
            calculation_place: 'www.my.ru',
            cashier_name: 'test',
            date_time: '2018-11-14T16:19:33',
            device_number: '00000000000000000001',
            document_number: '1323',
            fiscal_number: '9999078900005430',
            fiscal_sign: '13223',
            invoice_id: '1322223',
            ofd: 'Первый ОФД',
            ofd_receipt_url: 'http://url.com/adress',
            organization_inn: '7708806062',
            qr_code_url: 'https://qr.cloudpayments.ru/receipt?q=t%3d20181205T185000%26s%3d99.00%26fn%3d9999078900005430%26i%3d157347%26fp%3d1016954666%26n%3d1',
            reg_number: '322223',
            sender_email: 'sender@email.com',
            session_check_number: '12223',
            session_number: '1',
            settle_place: '117342, Москва, ул. Бутлерова, 17Б',
            transaction_id: 14442,
            type: 'Income'
          }
        )
      end
    end

    context 'failure' do
      before { stub_api_request('kassir/receipt/get/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('Error message') }
      its(:model) { is_expected.to be nil }
    end

    context 'failure with server error' do
      before { stub_api_request('kassir/receipt/get/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#get!' do
    let(:id) { 'Nr9eTaj' }

    subject { receipt.get!(id) }

    context 'without required attributes' do
      let(:id) { nil }

      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('kassir/receipt/get/successful').perform }

      it do
        is_expected.to eq(
          email: 'user@example.com',
          phone: nil,
          items: [{
            label: 'Product №1',
            price: 100,
            quantity: 1,
            amount: 100,
            department: nil,
            vat: 0,
            ean13: nil,
            agent_sign: nil,
            method: 6,
            object: 3,
            measurement_unit: 'шт',
            code: '1322',
            agent_data: nil,
            purveyor_data: nil
          }],
          taxation_system: 2,
          amounts: nil,
          is_bso: false,
          additional_data: {
            id: 'Nr9eTaj',
            account_id: 'user@example.com',
            amount: 1150,
            calculation_place: 'www.my.ru',
            cashier_name: 'test',
            date_time: '2018-11-14T16:19:33',
            device_number: '00000000000000000001',
            document_number: '1323',
            fiscal_number: '9999078900005430',
            fiscal_sign: '13223',
            invoice_id: '1322223',
            ofd: 'Первый ОФД',
            ofd_receipt_url: 'http://url.com/adress',
            organization_inn: '7708806062',
            qr_code_url: 'https://qr.cloudpayments.ru/receipt?q=t%3d20181205T185000%26s%3d99.00%26fn%3d9999078900005430%26i%3d157347%26fp%3d1016954666%26n%3d1',
            reg_number: '322223',
            sender_email: 'sender@email.com',
            session_check_number: '12223',
            session_number: '1',
            settle_place: '117342, Москва, ул. Бутлерова, 17Б',
            transaction_id: 14442,
            type: 'Income'
          }
        )
      end
    end

    context 'failure' do
      before { stub_api_request('kassir/receipt/get/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Error message') }
    end

    context 'failure with server error' do
      before { stub_api_request('kassir/receipt/get/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end
end
