# frozen_string_literal: true
require 'spec_helper'

RSpec.describe CloudPay::Client::Serializer do
  let(:encoded_data){ '{"Model":{"Id":123,"CurrencyCode":"RUB","Amount":120},"Success":true}' }
  let(:decoded_data){ { model: { id: 123, currency_code: 'RUB', amount: 120 }, success: true } }

  describe '#load' do
    subject { described_class.load(encoded_data) }
    it { is_expected.to eq(decoded_data) }
  end

  describe '#dump' do
    subject { described_class.dump(decoded_data) }
    it { is_expected.to eq(encoded_data) }
  end
end
