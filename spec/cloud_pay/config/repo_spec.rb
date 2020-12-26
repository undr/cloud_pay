# frozen_string_literal: true
require 'spec_helper'

RSpec.describe CloudPay::Config::Repo do
  subject(:repo) { described_class.new }

  before do
    repo.configure do |c|
      c.host = 'http://default.host'
    end

    repo.configure(:test) do |c|
      c.host = 'http://test.host'
    end
  end

  describe '#config' do
    context 'with default config' do
      subject { repo.config }

      it { is_expected.to be_instance_of(CloudPay::Config) }
      its(:host) { is_expected.to eq('http://default.host') }
    end

    context 'with default config' do
      subject { repo.config(:test) }

      it { is_expected.to be_instance_of(CloudPay::Config) }
      its(:host) { is_expected.to eq('http://test.host') }
    end

    context 'with undefined config name' do
      subject { repo.config(:anything) }

      it { is_expected.to be_instance_of(CloudPay::Config) }
      its(:host) { is_expected.to eq('https://api.cloudpayments.ru') }
    end

    context 'with config instance' do
      subject { repo.config(instance) }

      let(:instance) { CloudPay::Config.new(host: 'http://config.host') }

      it { is_expected.to be(instance) }
      its(:host) { is_expected.to eq('http://config.host') }
    end

    context 'with hash' do
      subject { repo.config(public_key: 'public_key') }

      it { is_expected.to be_instance_of(CloudPay::Config) }
      its(:host) { is_expected.to eq('http://default.host') }
      its(:public_key) { is_expected.to eq('public_key') }

      context 'when default config name is changed' do
        around do |example|
          CloudPay.with_config(:test) do
            example.run
          end
        end

        it { is_expected.to be_instance_of(CloudPay::Config) }
        its(:host) { is_expected.to eq('http://test.host') }
        its(:public_key) { is_expected.to eq('public_key') }
      end
    end

    context 'with unsupported value' do
      subject { repo.config('something') }

      it { expect { subject }.to raise_error(CloudPay::Error) }
    end
  end

  describe 'with_config and default' do
    it 'allows to change default config name' do
      expect(repo.default).to eq(:default)

      repo.with_config(:config_name) do
        expect(repo.default).to eq(:config_name)
      end

      expect(repo.default).to eq(:default)
    end
  end
end
