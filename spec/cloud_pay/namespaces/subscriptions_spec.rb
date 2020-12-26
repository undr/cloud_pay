# frozen_string_literal: true
require 'spec_helper'

RSpec.describe CloudPay::Subscriptions do
  let(:subs) { described_class.new(:test) }
  let(:attributes) do
    {
      token: "477BBA133C182267FE5F086924ABDC5DB71F77BFC27F01F2843F2CDC69D89F05",
      account_id: "user@example.com",
      description: "Monthly subscription on some service at example.com",
      email: "user@example.com",
      amount: 1.02,
      currency: "RUB",
      require_confirmation: false,
      start_date: "2014-08-06T16:46:29.5377246Z",
      interval: "Month",
      period: 1
    }
  end

  describe '#create' do
    subject { subs.create(attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('account_id, description, email, amount, currency, require_confirmation, start_date, interval, period attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('subscriptions/create/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to be nil }
      its(:model) do
        is_expected.to eq(
          id: 'sc_8cf8a9338fb8ebf7202b08d09c938',
          account_id: 'user@example.com',
          description: 'Monthly subscription on some service at example.com',
          email: 'user@example.com',
          amount: 1.02,
          currency_code: 0,
          currency: 'RUB',
          require_confirmation: false,
          start_date: '/Date(1407343589537)/',
          start_date_iso: '2014-08-09T11:49:41',
          interval_code: 1,
          interval: 'Month',
          period: 1,
          max_periods: nil,
          status_code: 0,
          status: 'Active',
          successful_transactions_number: 0,
          failed_transactions_number: 0,
          last_transaction_date: nil,
          last_transaction_date_iso: nil,
          next_transaction_date: '/Date(1407343589537)/',
          next_transaction_date_iso: '2014-08-09T11:49:41'
        )
      end
    end

    context 'failure' do
      before { stub_api_request('subscriptions/create/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to be nil }
      its(:model) { is_expected.to be nil }
    end

    context 'failure with server error' do
      before { stub_api_request('subscriptions/create/failed').to_return(status: 500, body: '') }

      it 'raises server error' do
        expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError)
      end
    end
  end

  describe '#create!' do
    subject { subs.create!(attributes) }

    context 'without required attributes' do
      let(:attributes) { {} }

      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('subscriptions/create/successful').perform }

      it do
        is_expected.to eq(
          id: 'sc_8cf8a9338fb8ebf7202b08d09c938',
          account_id: 'user@example.com',
          description: 'Monthly subscription on some service at example.com',
          email: 'user@example.com',
          amount: 1.02,
          currency_code: 0,
          currency: 'RUB',
          require_confirmation: false,
          start_date: '/Date(1407343589537)/',
          start_date_iso: '2014-08-09T11:49:41',
          interval_code: 1,
          interval: 'Month',
          period: 1,
          max_periods: nil,
          status_code: 0,
          status: 'Active',
          successful_transactions_number: 0,
          failed_transactions_number: 0,
          last_transaction_date: nil,
          last_transaction_date_iso: nil,
          next_transaction_date: '/Date(1407343589537)/',
          next_transaction_date_iso: '2014-08-09T11:49:41'
        )
      end
    end

    context 'failure' do
      before { stub_api_request('subscriptions/create/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Unknown Gateway Error') }
    end

    context 'failure with server error' do
      before { stub_api_request('subscriptions/create/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#get' do
    let(:id) { 'sc_8cf8a9338fb8ebf7202b08d09c938' }

    subject { subs.get(id) }

    context 'without required attributes' do
      let(:id) { nil }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('id attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('subscriptions/get/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to be nil }
      its(:model) do
        is_expected.to eq(
          id: 'sc_8cf8a9338fb8ebf7202b08d09c938',
          account_id: 'user@example.com',
          description: 'Monthly subscription on some service at example.com',
          email: 'user@example.com',
          amount: 1.02,
          currency_code: 0,
          currency: 'RUB',
          require_confirmation: false,
          start_date: '/Date(1407343589537)/',
          start_date_iso: '2014-08-09T11:49:41',
          interval_code: 1,
          interval: 'Month',
          period: 1,
          max_periods: nil,
          status_code: 0,
          status: 'Active',
          successful_transactions_number: 0,
          failed_transactions_number: 0,
          last_transaction_date: nil,
          last_transaction_date_iso: nil,
          next_transaction_date: '/Date(1407343589537)/',
          next_transaction_date_iso: '2014-08-09T11:49:41'
        )
      end
    end

    context 'failure' do
      before { stub_api_request('subscriptions/get/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to be nil }
      its(:model) { is_expected.to be nil }
    end

    context 'failure with server error' do
      before { stub_api_request('subscriptions/get/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#get!' do
    let(:id) { 'sc_8cf8a9338fb8ebf7202b08d09c938' }

    subject { subs.get!(id) }

    context 'without required attributes' do
      let(:id) { nil }

      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('subscriptions/get/successful').perform }

      it do
        is_expected.to eq(
          id: 'sc_8cf8a9338fb8ebf7202b08d09c938',
          account_id: 'user@example.com',
          description: 'Monthly subscription on some service at example.com',
          email: 'user@example.com',
          amount: 1.02,
          currency_code: 0,
          currency: 'RUB',
          require_confirmation: false,
          start_date: '/Date(1407343589537)/',
          start_date_iso: '2014-08-09T11:49:41',
          interval_code: 1,
          interval: 'Month',
          period: 1,
          max_periods: nil,
          status_code: 0,
          status: 'Active',
          successful_transactions_number: 0,
          failed_transactions_number: 0,
          last_transaction_date: nil,
          last_transaction_date_iso: nil,
          next_transaction_date: '/Date(1407343589537)/',
          next_transaction_date_iso: '2014-08-09T11:49:41'
        )
      end
    end

    context 'failure' do
      before { stub_api_request('subscriptions/get/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Unknown Gateway Error') }
    end

    context 'failure with server error' do
      before { stub_api_request('subscriptions/get/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#find' do
    let(:id) { 'user@example.com' }

    subject { subs.find(id) }

    context 'without required attributes' do
      let(:id) { nil }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('account_id attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('subscriptions/find/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to be nil }
      its(:model) do
        is_expected.to eq([{
          id: 'sc_8cf8a9338fb8ebf7202b08d09c938',
          account_id: 'user@example.com',
          description: 'Monthly subscription on some service at example.com',
          email: 'user@example.com',
          amount: 1.02,
          currency_code: 0,
          currency: 'RUB',
          require_confirmation: false,
          start_date: '/Date(1407343589537)/',
          start_date_iso: '2014-08-09T11:49:41',
          interval_code: 1,
          interval: 'Month',
          period: 1,
          max_periods: nil,
          status_code: 0,
          status: 'Active',
          successful_transactions_number: 0,
          failed_transactions_number: 0,
          last_transaction_date: nil,
          last_transaction_date_iso: nil,
          next_transaction_date: '/Date(1407343589537)/',
          next_transaction_date_iso: '2014-08-09T11:49:41'
        }])
      end
    end

    context 'failure' do
      before { stub_api_request('subscriptions/find/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to be nil }
      its(:model) { is_expected.to be nil }
    end

    context 'failure with server error' do
      before { stub_api_request('subscriptions/find/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#find!' do
    let(:id) { 'user@example.com' }

    subject { subs.find!(id) }

    context 'without required attributes' do
      let(:id) { nil }

      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('subscriptions/find/successful').perform }

      it do
        is_expected.to eq([{
          id: 'sc_8cf8a9338fb8ebf7202b08d09c938',
          account_id: 'user@example.com',
          description: 'Monthly subscription on some service at example.com',
          email: 'user@example.com',
          amount: 1.02,
          currency_code: 0,
          currency: 'RUB',
          require_confirmation: false,
          start_date: '/Date(1407343589537)/',
          start_date_iso: '2014-08-09T11:49:41',
          interval_code: 1,
          interval: 'Month',
          period: 1,
          max_periods: nil,
          status_code: 0,
          status: 'Active',
          successful_transactions_number: 0,
          failed_transactions_number: 0,
          last_transaction_date: nil,
          last_transaction_date_iso: nil,
          next_transaction_date: '/Date(1407343589537)/',
          next_transaction_date_iso: '2014-08-09T11:49:41'
        }])
      end
    end

    context 'failure' do
      before { stub_api_request('subscriptions/find/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Unknown Gateway Error') }
    end

    context 'failure with server error' do
      before { stub_api_request('subscriptions/find/failed').to_return(status: 500, body: '') }

      it { expect { subject.find('user@example.com') }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#update' do
    subject { subs.update(id, attributes) }

    let(:attributes) { { description: 'Rate №5', amount: 1200, currency: 'RUB' } }
    let(:id) { 'sc_8cf8a9338fb8ebf7202b08d09c938' }

    context 'without required attributes' do
      let(:id) { nil }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('id attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('subscriptions/update/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to be nil }
      its(:model)  do
        is_expected.to eq(
          id: 'sc_8cf8a9338fb8ebf7202b08d09c938',
          account_id: 'user@example.com',
          description: 'Rate №5',
          email: 'user@example.com',
          amount: 1200,
          currency_code: 0,
          currency: 'RUB',
          require_confirmation: false,
          start_date: '/Date(1407343589537)/',
          start_date_iso: '2014-08-09T11:49:41',
          interval_code: 1,
          interval: 'Month',
          period: 1,
          max_periods: nil,
          status_code: 0,
          status: 'Active',
          successful_transactions_number: 0,
          failed_transactions_number: 0,
          last_transaction_date: nil,
          last_transaction_date_iso: nil,
          next_transaction_date: '/Date(1407343589537)/',
          next_transaction_date_iso: '2014-08-09T11:49:41'
        )
      end
    end

    context 'failure' do
      before { stub_api_request('subscriptions/update/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to be nil }
      its(:model) { is_expected.to be nil }
    end

    context 'failure with server error' do
      before { stub_api_request('subscriptions/update/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#update!' do
    subject { subs.update!(id, attributes) }

    let(:attributes) { { description: 'Rate №5', amount: 1200, currency: 'RUB' } }
    let(:id) { 'sc_8cf8a9338fb8ebf7202b08d09c938' }

    context 'without required attributes' do
      let(:id) { nil }

      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('subscriptions/update/successful').perform }

      it do
        is_expected.to eq(
          id: 'sc_8cf8a9338fb8ebf7202b08d09c938',
          account_id: 'user@example.com',
          description: 'Rate №5',
          email: 'user@example.com',
          amount: 1200,
          currency_code: 0,
          currency: 'RUB',
          require_confirmation: false,
          start_date: '/Date(1407343589537)/',
          start_date_iso: '2014-08-09T11:49:41',
          interval_code: 1,
          interval: 'Month',
          period: 1,
          max_periods: nil,
          status_code: 0,
          status: 'Active',
          successful_transactions_number: 0,
          failed_transactions_number: 0,
          last_transaction_date: nil,
          last_transaction_date_iso: nil,
          next_transaction_date: '/Date(1407343589537)/',
          next_transaction_date_iso: '2014-08-09T11:49:41'
        )
      end
    end

    context 'failure' do
      before { stub_api_request('subscriptions/update/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Unknown Gateway Error') }
    end

    context 'failure with server error' do
      before { stub_api_request('subscriptions/update/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#cancel' do
    subject { subs.cancel(id) }

    let(:id) { 'sc_8cf8a9338fb8ebf7202b08d09c938' }

    context 'without required attributes' do
      let(:id) { nil }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to eq('id attributes are required') }
      its(:model) { is_expected.to be nil }
    end

    context 'success case' do
      before { stub_api_request('subscriptions/cancel/successful').perform }

      its(:success?) { is_expected.to be true }
      its(:error_message) { is_expected.to be nil }
      its(:model) { is_expected.to be nil }
    end

    context 'failure' do
      before { stub_api_request('subscriptions/cancel/failed').perform }

      its(:success?) { is_expected.to be false }
      its(:error_message) { is_expected.to be nil }
      its(:model) { is_expected.to be nil }
    end

    context 'failure with server error' do
      before { stub_api_request('subscriptions/cancel/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end

  describe '#cancel!' do
    subject { subs.cancel!(id) }

    let(:id) { 'sc_8cf8a9338fb8ebf7202b08d09c938' }

    context 'without required attributes' do
      let(:id) { nil }

      it { expect { subject }.to raise_error(CloudPay::ValidationError) }
    end

    context 'success case' do
      before { stub_api_request('subscriptions/cancel/successful').perform }

      it { expect(subject).to be true }
    end

    context 'failure' do
      before { stub_api_request('subscriptions/cancel/failed').perform }

      it { expect { subject }.to raise_error(CloudPay::GatewayError, 'Unknown Gateway Error') }
    end

    context 'failure with server error' do
      before { stub_api_request('subscriptions/cancel/failed').to_return(status: 500, body: '') }

      it { expect { subject }.to raise_error(CloudPay::HttpErrors::InternalServerError) }
    end
  end
end
