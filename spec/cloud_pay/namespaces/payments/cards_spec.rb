# frozen_string_literal: true
require 'spec_helper'

RSpec.describe CloudPay::Payments::Cards do
  let(:attributes) do
    {
      amount: 10,
      currency: 'RUB',
      ip_address: '127.0.0.1',
      description: 'Order №1234567 in shop example.com',
      account_id: 'user_x',
      name: 'CARDHOLDER NAME',
      card_cryptogram_packet: '01492500008719030128SMfLeYdKp5dSQVIiO5l6ZCJiPdel4uDjdFTTz1UnXY'
    }
  end

  subject(:cards) { described_class.new(:test) }

  describe '#charge' do
    subject { cards.charge(attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('amount, ip_address, card_cryptogram_packet attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('payments/cards/charge/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to eq('ayment successfully completed') }
      its(:model) do
        is_expected.to eq(
          transaction_id: 504,
          amount: 10.00000,
          currency: 'RUB',
          currency_code: 0,
          invoice_id: '1234567',
          account_id: 'user_x',
          email: nil,
          description: 'Оrder №1234567 in shop example.com',
          json_data: nil,
          created_date: '/Date(1401718880000)/',
          created_date_iso: '2014-08-09T11:49:41',
          auth_date: '/Date(1401733880523)/',
          auth_date_iso: '2014-08-09T11:49:42',
          confirm_date: '/Date(1401733880523)/',
          confirm_date_iso: '2014-08-09T11:49:42',
          auth_code: '123456',
          test_mode: true,
          ip_address: '195.91.194.13',
          ip_country: 'RU',
          ip_city: 'Ufa',
          ip_region: 'Республика Башкортостан',
          ip_district: 'Приволжский федеральный округ',
          ip_latitude: 54.7355,
          ip_longitude: 55.991982,
          card_first_six: '411111',
          card_last_four: '1111',
          card_exp_date: '05/19',
          card_type: 'Visa',
          card_type_code: 0,
          issuer: 'Sberbank of Russia',
          issuer_bank_country: 'RU',
          status: 'Completed',
          status_code: 3,
          reason: 'Approved',
          reason_code: 0,
          card_holder_message: 'ayment successfully completed',
          name: 'CARDHOLDER NAME',
          token: 'a4e67841-abb0-42de-a364-d1d8f9f4b3c0'
        )
      end
    end

    context 'failure' do
      before { stub_api_request('payments/cards/charge/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('Error message') }
      its(:model) { is_expected.to be nil }
    end

    context 'failure with gateway error' do
      before { stub_api_request('payments/cards/charge/gateway_failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('Not enough funds on the card') }
      its(:model) do
        is_expected.to eq(
           transaction_id: 504,
           amount: 10.0,
           currency: 'RUB',
           currency_code: 0,
           payment_amount: 10.0,
           payment_currency: 'RUB',
           payment_currency_code: 0,
           invoice_id: '1234567',
           account_id: 'user_x',
           email: nil,
           description: 'Order №1234567 in shop example.com',
           json_data: nil,
           created_date: '/Date(1401718880000)/',
           created_date_iso: '2014-08-09T11:49:41',
           test_mode: true,
           ip_address: '195.91.194.13',
           ip_country: 'RU',
           ip_city: 'Ufa',
           ip_region: 'Республика Башкортостан',
           ip_district: 'Приволжский федеральный округ',
           ip_latitude: 54.7355,
           ip_longitude: 55.991982,
           card_first_six: '411111',
           card_last_four: '1111',
           card_exp_date: '05/19',
           card_type: 'Visa',
           card_type_code: 0,
           issuer: 'Sberbank of Russia',
           issuer_bank_country: 'RU',
           status: 'Declined',
           status_code: 5,
           reason: 'InsufficientFunds',
           reason_code: 5051,
           card_holder_message: 'Not enough funds on the card',
           name: 'CARDHOLDER NAME'
        )
      end
    end

    context 'failure with server error' do
      before { stub_api_request('payments/cards/charge/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#charge!' do
    subject { cards.charge!(attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('payments/cards/charge/successful').perform }

      it do
        is_expected.to eq(
          transaction_id: 504,
          amount: 10.00000,
          currency: 'RUB',
          currency_code: 0,
          invoice_id: '1234567',
          account_id: 'user_x',
          email: nil,
          description: 'Оrder №1234567 in shop example.com',
          json_data: nil,
          created_date: '/Date(1401718880000)/',
          created_date_iso: '2014-08-09T11:49:41',
          auth_date: '/Date(1401733880523)/',
          auth_date_iso: '2014-08-09T11:49:42',
          confirm_date: '/Date(1401733880523)/',
          confirm_date_iso: '2014-08-09T11:49:42',
          auth_code: '123456',
          test_mode: true,
          ip_address: '195.91.194.13',
          ip_country: 'RU',
          ip_city: 'Ufa',
          ip_region: 'Республика Башкортостан',
          ip_district: 'Приволжский федеральный округ',
          ip_latitude: 54.7355,
          ip_longitude: 55.991982,
          card_first_six: '411111',
          card_last_four: '1111',
          card_exp_date: '05/19',
          card_type: 'Visa',
          card_type_code: 0,
          issuer: 'Sberbank of Russia',
          issuer_bank_country: 'RU',
          status: 'Completed',
          status_code: 3,
          reason: 'Approved',
          reason_code: 0,
          card_holder_message: 'ayment successfully completed',
          name: 'CARDHOLDER NAME',
          token: 'a4e67841-abb0-42de-a364-d1d8f9f4b3c0'
        )
      end
    end

    context 'failure' do
      before { stub_api_request('payments/cards/charge/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Error message') }
    end

    context 'failure with server error' do
      before { stub_api_request('payments/cards/charge/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#auth' do
    subject { cards.auth(attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('amount, ip_address, card_cryptogram_packet attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('payments/cards/auth/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to eq('ayment successfully completed') }
      its(:model) do
        is_expected.to eq(
          transaction_id: 504,
          amount: 10.00000,
          currency: 'RUB',
          currency_code: 0,
          invoice_id: '1234567',
          account_id: 'user_x',
          email: nil,
          description: 'Оrder №1234567 in shop example.com',
          json_data: nil,
          created_date: '/Date(1401718880000)/',
          created_date_iso: '2014-08-09T11:49:41',
          auth_date: '/Date(1401733880523)/',
          auth_date_iso: '2014-08-09T11:49:42',
          confirm_date: '/Date(1401733880523)/',
          confirm_date_iso: '2014-08-09T11:49:42',
          auth_code: '123456',
          test_mode: true,
          ip_address: '195.91.194.13',
          ip_country: 'RU',
          ip_city: 'Ufa',
          ip_region: 'Республика Башкортостан',
          ip_district: 'Приволжский федеральный округ',
          ip_latitude: 54.7355,
          ip_longitude: 55.991982,
          card_first_six: '411111',
          card_last_four: '1111',
          card_exp_date: '05/19',
          card_type: 'Visa',
          card_type_code: 0,
          issuer: 'Sberbank of Russia',
          issuer_bank_country: 'RU',
          status: 'Completed',
          status_code: 3,
          reason: 'Approved',
          reason_code: 0,
          card_holder_message: 'ayment successfully completed',
          name: 'CARDHOLDER NAME',
          token: 'a4e67841-abb0-42de-a364-d1d8f9f4b3c0'
        )
      end
    end

    context 'failure' do
      before { stub_api_request('payments/cards/auth/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('Error message') }
      its(:model) { is_expected.to be nil }
    end

    context 'failure with gateway error' do
      before { stub_api_request('payments/cards/auth/gateway_failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('Not enough funds on the card') }
      its(:model) do
        is_expected.to eq(
           transaction_id: 504,
           amount: 10.0,
           currency: 'RUB',
           currency_code: 0,
           payment_amount: 10.0,
           payment_currency: 'RUB',
           payment_currency_code: 0,
           invoice_id: '1234567',
           account_id: 'user_x',
           email: nil,
           description: 'Order №1234567 in shop example.com',
           json_data: nil,
           created_date: '/Date(1401718880000)/',
           created_date_iso: '2014-08-09T11:49:41',
           test_mode: true,
           ip_address: '195.91.194.13',
           ip_country: 'RU',
           ip_city: 'Ufa',
           ip_region: 'Республика Башкортостан',
           ip_district: 'Приволжский федеральный округ',
           ip_latitude: 54.7355,
           ip_longitude: 55.991982,
           card_first_six: '411111',
           card_last_four: '1111',
           card_exp_date: '05/19',
           card_type: 'Visa',
           card_type_code: 0,
           issuer: 'Sberbank of Russia',
           issuer_bank_country: 'RU',
           status: 'Declined',
           status_code: 5,
           reason: 'InsufficientFunds',
           reason_code: 5051,
           card_holder_message: 'Not enough funds on the card',
           name: 'CARDHOLDER NAME'
        )
      end
    end

    context 'failure with server error' do
      before { stub_api_request('payments/cards/auth/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#auth!' do
    subject { cards.auth!(attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('payments/cards/auth/successful').perform }

      it do
        is_expected.to eq(
          transaction_id: 504,
          amount: 10.00000,
          currency: 'RUB',
          currency_code: 0,
          invoice_id: '1234567',
          account_id: 'user_x',
          email: nil,
          description: 'Оrder №1234567 in shop example.com',
          json_data: nil,
          created_date: '/Date(1401718880000)/',
          created_date_iso: '2014-08-09T11:49:41',
          auth_date: '/Date(1401733880523)/',
          auth_date_iso: '2014-08-09T11:49:42',
          confirm_date: '/Date(1401733880523)/',
          confirm_date_iso: '2014-08-09T11:49:42',
          auth_code: '123456',
          test_mode: true,
          ip_address: '195.91.194.13',
          ip_country: 'RU',
          ip_city: 'Ufa',
          ip_region: 'Республика Башкортостан',
          ip_district: 'Приволжский федеральный округ',
          ip_latitude: 54.7355,
          ip_longitude: 55.991982,
          card_first_six: '411111',
          card_last_four: '1111',
          card_exp_date: '05/19',
          card_type: 'Visa',
          card_type_code: 0,
          issuer: 'Sberbank of Russia',
          issuer_bank_country: 'RU',
          status: 'Completed',
          status_code: 3,
          reason: 'Approved',
          reason_code: 0,
          card_holder_message: 'ayment successfully completed',
          name: 'CARDHOLDER NAME',
          token: 'a4e67841-abb0-42de-a364-d1d8f9f4b3c0'
        )
      end
    end

    context 'failure' do
      before { stub_api_request('payments/cards/auth/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Error message') }
    end

    context 'failure with server error' do
      before { stub_api_request('payments/cards/auth/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#post3ds' do
    let(:id) { 12345 }
    let(:attributes) { { pa_res: 'eJxVUdtugkAQ' } }

    subject { cards.post3ds(id, attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('transaction_id, pa_res attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('payments/cards/post3ds/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to eq('ayment successfully completed') }
      its(:model) do
        is_expected.to eq(
          transaction_id: 504,
          amount: 10.00000,
          currency: 'RUB',
          currency_code: 0,
          invoice_id: '1234567',
          account_id: 'user_x',
          email: nil,
          description: 'Оrder №1234567 in shop example.com',
          json_data: nil,
          created_date: '/Date(1401718880000)/',
          created_date_iso: '2014-08-09T11:49:41',
          auth_date: '/Date(1401733880523)/',
          auth_date_iso: '2014-08-09T11:49:42',
          confirm_date: '/Date(1401733880523)/',
          confirm_date_iso: '2014-08-09T11:49:42',
          auth_code: '123456',
          test_mode: true,
          ip_address: '195.91.194.13',
          ip_country: 'RU',
          ip_city: 'Ufa',
          ip_region: 'Республика Башкортостан',
          ip_district: 'Приволжский федеральный округ',
          ip_latitude: 54.7355,
          ip_longitude: 55.991982,
          card_first_six: '411111',
          card_last_four: '1111',
          card_exp_date: '05/19',
          card_type: 'Visa',
          card_type_code: 0,
          issuer: 'Sberbank of Russia',
          issuer_bank_country: 'RU',
          status: 'Completed',
          status_code: 3,
          reason: 'Approved',
          reason_code: 0,
          card_holder_message: 'ayment successfully completed',
          name: 'CARDHOLDER NAME',
          token: 'a4e67841-abb0-42de-a364-d1d8f9f4b3c0'
        )
      end
    end

    context 'failure' do
      before { stub_api_request('payments/cards/post3ds/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('Error message') }
      its(:model) { is_expected.to be nil }
    end

    context 'failure with gateway error' do
      before { stub_api_request('payments/cards/post3ds/gateway_failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('Not enough funds on the card') }
      its(:model) do
        is_expected.to eq(
           transaction_id: 504,
           amount: 10.0,
           currency: 'RUB',
           currency_code: 0,
           payment_amount: 10.0,
           payment_currency: 'RUB',
           payment_currency_code: 0,
           invoice_id: '1234567',
           account_id: 'user_x',
           email: nil,
           description: 'Order №1234567 in shop example.com',
           json_data: nil,
           created_date: '/Date(1401718880000)/',
           created_date_iso: '2014-08-09T11:49:41',
           test_mode: true,
           ip_address: '195.91.194.13',
           ip_country: 'RU',
           ip_city: 'Ufa',
           ip_region: 'Республика Башкортостан',
           ip_district: 'Приволжский федеральный округ',
           ip_latitude: 54.7355,
           ip_longitude: 55.991982,
           card_first_six: '411111',
           card_last_four: '1111',
           card_exp_date: '05/19',
           card_type: 'Visa',
           card_type_code: 0,
           issuer: 'Sberbank of Russia',
           issuer_bank_country: 'RU',
           status: 'Declined',
           status_code: 5,
           reason: 'InsufficientFunds',
           reason_code: 5051,
           card_holder_message: 'Not enough funds on the card',
           name: 'CARDHOLDER NAME'
        )
      end
    end

    context 'failure with server error' do
      before { stub_api_request('payments/cards/post3ds/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#post3ds!' do
    let(:id) { 12345 }
    let(:attributes) { { pa_res: 'eJxVUdtugkAQ' } }

    subject { cards.post3ds!(id, attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('payments/cards/post3ds/successful').perform }

      it do
        is_expected.to eq(
          transaction_id: 504,
          amount: 10.00000,
          currency: 'RUB',
          currency_code: 0,
          invoice_id: '1234567',
          account_id: 'user_x',
          email: nil,
          description: 'Оrder №1234567 in shop example.com',
          json_data: nil,
          created_date: '/Date(1401718880000)/',
          created_date_iso: '2014-08-09T11:49:41',
          auth_date: '/Date(1401733880523)/',
          auth_date_iso: '2014-08-09T11:49:42',
          confirm_date: '/Date(1401733880523)/',
          confirm_date_iso: '2014-08-09T11:49:42',
          auth_code: '123456',
          test_mode: true,
          ip_address: '195.91.194.13',
          ip_country: 'RU',
          ip_city: 'Ufa',
          ip_region: 'Республика Башкортостан',
          ip_district: 'Приволжский федеральный округ',
          ip_latitude: 54.7355,
          ip_longitude: 55.991982,
          card_first_six: '411111',
          card_last_four: '1111',
          card_exp_date: '05/19',
          card_type: 'Visa',
          card_type_code: 0,
          issuer: 'Sberbank of Russia',
          issuer_bank_country: 'RU',
          status: 'Completed',
          status_code: 3,
          reason: 'Approved',
          reason_code: 0,
          card_holder_message: 'ayment successfully completed',
          name: 'CARDHOLDER NAME',
          token: 'a4e67841-abb0-42de-a364-d1d8f9f4b3c0'
        )
      end
    end

    context 'failure' do
      before { stub_api_request('payments/cards/post3ds/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Error message') }
    end

    context 'failure with server error' do
      before { stub_api_request('payments/cards/post3ds/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#topup' do
    let(:attributes) do
      {
        name: 'CARDHOLDER NAME',
        card_cryptogram_packet: '01492500008719030128SMfLeYdKp5dSQVIiO5l6ZCJiPdel4uDjdFTTz1UnXY',
        amount: 1,
        account_id: 'user@example.com',
        currency: 'RUB',
        invoice_id: '1234567'
      }
    end

    subject { cards.topup(attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('name, amount, card_cryptogram_packet, account_id, currency attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('payments/cards/topup/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to eq('Оплата успешно проведена') }
      its(:model) do
        is_expected.to eq(
          public_id: 'pk_b9b86395c99782f0d16386d83e5d8',
          transaction_id: 100551,
          amount: 1,
          currency: 'RUB',
          payment_amount: 1,
          payment_currency: 'RUB',
          account_id: 'user@example.com',
          email: nil,
          description: nil,
          json_data: nil,
          created_date: '/Date(1517943890884)/',
          payout_date: '/Date(1517950800000)/',
          payout_date_iso: '2018-02-07T00:00:00',
          payout_amount: 1,
          created_date_iso: '2018-02-06T19:04:50',
          auth_date: '/Date(1517943899268)/',
          auth_date_iso: '2018-02-06T19:04:59',
          confirm_date: '/Date(1517943899268)/',
          confirm_date_iso: '2018-02-06T19:04:59',
          auth_code: '031365',
          test_mode: false,
          rrn: '568879820',
          original_transaction_id: nil,
          ip_address: '185.8.6.164',
          ip_country: 'RU',
          ip_city: 'Москва',
          ip_region: nil,
          ip_district: 'Москва',
          ip_latitude: 55.75222,
          ip_longitude: 37.61556,
          card_first_six: '411111',
          card_last_four: '1111',
          card_exp_date: '12/22',
          card_type: 'Visa',
          card_type_code: 0,
          status: 'Completed',
          status_code: 3,
          culture_name: 'ru',
          reason: 'Approved',
          reason_code: 0,
          card_holder_message: 'Оплата успешно проведена',
          type: 2,
          refunded: false,
          name: 'WQER',
          subscription_id: nil,
          gateway_name: 'Tinkoff Payout'
        )
      end
    end

    context 'failure' do
      before { stub_api_request('payments/cards/topup/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('Error message') }
      its(:model) { is_expected.to be nil }
    end

    context 'failure with server error' do
      before { stub_api_request('payments/cards/topup/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#topup!' do
    let(:attributes) do
      {
        name: 'CARDHOLDER NAME',
        card_cryptogram_packet: '01492500008719030128SMfLeYdKp5dSQVIiO5l6ZCJiPdel4uDjdFTTz1UnXY',
        amount: 1,
        account_id: 'user@example.com',
        currency: 'RUB',
        invoice_id: '1234567'
      }
    end

    subject { cards.topup!(attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('payments/cards/topup/successful').perform }

      it do
        is_expected.to eq(
          public_id: 'pk_b9b86395c99782f0d16386d83e5d8',
          transaction_id: 100551,
          amount: 1,
          currency: 'RUB',
          payment_amount: 1,
          payment_currency: 'RUB',
          account_id: 'user@example.com',
          email: nil,
          description: nil,
          json_data: nil,
          created_date: '/Date(1517943890884)/',
          payout_date: '/Date(1517950800000)/',
          payout_date_iso: '2018-02-07T00:00:00',
          payout_amount: 1,
          created_date_iso: '2018-02-06T19:04:50',
          auth_date: '/Date(1517943899268)/',
          auth_date_iso: '2018-02-06T19:04:59',
          confirm_date: '/Date(1517943899268)/',
          confirm_date_iso: '2018-02-06T19:04:59',
          auth_code: '031365',
          test_mode: false,
          rrn: '568879820',
          original_transaction_id: nil,
          ip_address: '185.8.6.164',
          ip_country: 'RU',
          ip_city: 'Москва',
          ip_region: nil,
          ip_district: 'Москва',
          ip_latitude: 55.75222,
          ip_longitude: 37.61556,
          card_first_six: '411111',
          card_last_four: '1111',
          card_exp_date: '12/22',
          card_type: 'Visa',
          card_type_code: 0,
          status: 'Completed',
          status_code: 3,
          culture_name: 'ru',
          reason: 'Approved',
          reason_code: 0,
          card_holder_message: 'Оплата успешно проведена',
          type: 2,
          refunded: false,
          name: 'WQER',
          subscription_id: nil,
          gateway_name: 'Tinkoff Payout'
        )
      end
    end

    context 'failure' do
      before { stub_api_request('payments/cards/topup/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Error message') }
    end

    context 'failure with server error' do
      before { stub_api_request('payments/cards/topup/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end
end
