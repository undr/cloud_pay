# frozen_string_literal: true
require 'spec_helper'

class TestNamespace < CloudPay::Namespace
  path_prefix '/testnamespace'
end

RSpec.describe CloudPay::Namespace do
  let(:config) { CloudPay.config(:test) }
  let(:request_body) { '{"Amount":120,"CurrencyCode":"RUB"}' }
  let(:request_params) { { amount: 120, currency_code: 'RUB' } }
  let(:request_headers) { { 'Content-Type' => 'application/json' } }
  let(:response_headers) { { 'Content-Type' => 'application/json' } }
  let(:successful_body) { '{"Model":{},"Success":true}' }
  let(:failed_body) { '{"Success":false,"Message":"Error message"}' }
  let(:failed_transaction_body) do
    '{"Model":{"ReasonCode":5041,"CardHolderMessage":"Contact your bank"},"Success":false}'
  end

  subject(:namespace) { TestNamespace.new(config) }

  def stub_api(path)
    stub_request(:post, "http://localhost:9292#{path}").with(
      body: request_body,
      headers: request_headers,
      basic_auth: ['user', 'pass']
    )
  end

  describe '#initialize' do
    before do
      @repo, CloudPay.config_repo = CloudPay.config_repo, CloudPay::Config::Repo.new

      CloudPay.configure do |c|
        c.host = 'http://default.host'
      end

      CloudPay.configure(:somename) do |c|
        c.host = 'http://somename.host'
      end
    end

    after  { CloudPay.config_repo = @repo }

    context 'without any args' do
      subject { TestNamespace.new.client.config }

      its(:host) { is_expected.to eq('http://default.host') }
    end

    context 'with nil' do
      subject { TestNamespace.new(nil).client.config }

      its(:host) { is_expected.to eq('http://default.host') }
    end

    context 'with predefined config' do
      subject { TestNamespace.new(:somename).client.config }

      its(:host) { is_expected.to eq('http://somename.host') }
    end

    context 'with unknown config' do
      subject { TestNamespace.new(:unknown).client.config }

      its(:host) { is_expected.to eq('https://api.cloudpayments.ru') }
    end

    context 'with hash' do
      subject { TestNamespace.new(host: 'http://hash.host').client.config }

      its(:host) { is_expected.to eq('http://hash.host') }
    end

    context 'with client' do
      let(:client) { CloudPay.client(:test) }

      subject { TestNamespace.new(client).client }

      it { is_expected.to be(client) }
    end

    context 'with unsupported value' do
      it { expect { TestNamespace.new('something') }.to raise_error(CloudPay::Error) }
    end
  end

  describe '#request' do
    context 'without path' do
      subject { namespace.request(nil, request_params) }

      before { stub_api('/testnamespace').to_return(body: successful_body, headers: response_headers) }

      it { is_expected.to be_success }
      its(:model) { is_expected.to eq({}) }
    end

    context 'with path' do
      subject { namespace.request(:path, request_params) }

      before { stub_api('/testnamespace/path').to_return(body: successful_body, headers: response_headers) }

      it { is_expected.to be_success }
      its(:model) { is_expected.to eq({}) }
    end

    context 'with path and parent path' do
      subject { namespace.request(:path, request_params, path_prefix: '/v2/testnamespace') }

      before { stub_api('/v2/testnamespace/path').to_return(body: successful_body, headers: response_headers) }

      it { is_expected.to be_success }
      its(:model) { is_expected.to eq({}) }
    end

    context 'with idempotency key' do
      subject { namespace.request(:path, request_params, idempotency_key: idempotency_key) }

      let(:idempotency_key) { 'unique string' }

      before do
        stub_api('/testnamespace/path').
          and_return(body: successful_body, headers: response_headers.merge('X-Request-ID' => idempotency_key))
      end

      it { is_expected.to be_success }
      its(:model) { is_expected.to eq({}) }
    end

    context 'when status is greater than 300' do
      before { stub_api('/testnamespace/path').and_return(status: 404, headers: request_headers) }

      it { expect { subject.request(:path, request_params) }.to raise_error(CloudPay::HttpErrors::NotFound) }
    end

    context 'when failed request' do
      subject { namespace.request(:path, request_params) }

      before { stub_api('/testnamespace/path').and_return(body: failed_body, headers: response_headers) }

      it { is_expected.not_to be_success }
      its(:message) { is_expected.to eq('Error message') }
      its(:gateway_message) { is_expected.to be nil }
      its(:error_message) { is_expected.to eq('Error message') }
      its(:model) { is_expected.to be nil }
    end

    context 'when failed request with raise exception' do
      before { stub_api('/testnamespace/path').and_return(body: failed_body, headers: response_headers) }

      it do
        expect {
          subject.request(:path, request_params, raise_error: true)
        }.to raise_error(CloudPay::GatewayError, 'Error message')
      end
    end

    context 'when failed transaction' do
      subject { namespace.request(:path, request_params) }

      before { stub_api('/testnamespace/path').to_return(body: failed_transaction_body, headers: response_headers) }

      it { is_expected.not_to be_success }
      its(:message) { is_expected.to be nil }
      its(:gateway_message) { is_expected.to eq('Contact your bank') }
      its(:error_message) { is_expected.to eq('Contact your bank') }
      its(:model) { is_expected.to eq(reason_code: 5041, card_holder_message: 'Contact your bank') }
    end

    context 'when failed transaction with raise exception' do
      before { stub_api('/testnamespace/path').to_return(body: failed_transaction_body, headers: response_headers) }

      it do
        expect {
          subject.request(:path, request_params, raise_error: true)
        }.to raise_error(CloudPay::GatewayErrors::LostCard, 'Contact your bank')
      end
    end
  end

  describe '#run_if_valid' do
    let(:options) { { raise_error: true } }
    let(:attributes) { { key1: 'v1', key2: 'v2', key3: 'v3' } }
    let(:invalid_attributes) { { key1: nil, key2: '', key3: 'v3' } }

    it 'returns failed result' do
      result = subject.run_if_valid(invalid_attributes, [:key1, :key2]) do |_attrs|
        raise 'it should not be invoked'
      end

      expect(result).to_not be_success
      expect(result.error_message).to eq('key1, key2 attributes are required')
      expect(result.model).to be nil
    end

    it 'returns failed result' do
      result = subject.run_if_valid(invalid_attributes) do |_attrs|
        raise 'it should not be invoked'
      end

      expect(result).to_not be_success
      expect(result.error_message).to eq('key1, key2, key3 attributes are required')
      expect(result.model).to be nil
    end

    it 'raises validation error with raise instruction' do
      expect {
        subject.run_if_valid(invalid_attributes, [:key1, :key2], options) do |_attrs|
          raise 'it should not be invoked'
        end
      }.to raise_error(CloudPay::ValidationError, 'key1, key2 attributes are required')
    end

    it 'raises validation error with raise instruction' do
      expect {
        subject.run_if_valid(invalid_attributes, options) do |_attrs|
          raise 'it should not be invoked'
        end
      }.to raise_error(CloudPay::ValidationError, 'key1, key2, key3 attributes are required')
    end

    it 'yields attributes' do
      expect { |b|
        subject.run_if_valid(attributes, [:key1, :key2], &b)
      }.to yield_with_args(attributes)
    end

    it 'yields attributes with raise instruction' do
      expect { |b|
        subject.run_if_valid(attributes, [:key1, :key2], options, &b)
      }.to yield_with_args(attributes)
    end

    it 'yields attributes' do
      expect { |b|
        subject.run_if_valid(attributes, &b)
      }.to yield_with_args(attributes)
    end

    it 'yields attributes with raise instruction' do
      expect { |b|
        subject.run_if_valid(attributes, options, &b)
      }.to yield_with_args(attributes)
    end
  end
end
