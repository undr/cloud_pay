# frozen_string_literal: true
require 'spec_helper'

RSpec.describe CloudPay::Client::Response do
  let(:status) { 200 }
  let(:headers) { { 'content-type' => 'application/json' } }
  let(:body) do
    '{"Model":{"Id":123,"CurrencyCode":"RUB","Amount":120},"Success":true}'.
      dup.
      force_encoding('CP1251').
      freeze
  end

  subject { described_class.new(status, body, headers) }

  describe '#body' do
    its(:body) { is_expected.to eq(model: { id: 123, currency_code: 'RUB', amount: 120 }, success: true) }

    context 'wnen content type does not match /json/' do
      let(:headers) { { 'content-type' => 'text/plain' } }

      its(:body) { is_expected.to eq(body) }
      specify { expect(subject.body.encoding.name).to eq('UTF-8') }
    end
  end

  describe '#origin_body' do
    its(:origin_body) { is_expected.to eq(body) }

    context 'wnen content type does not match /json/' do
      let(:headers) { { 'content-type' => 'text/plain' } }

      its(:origin_body) { is_expected.to eq(body) }
    end
  end

  describe '#headers' do
    its(:headers) { is_expected.to eq(headers) }
  end

  describe '#status' do
    its(:status) { is_expected.to eq(status) }
  end
end
