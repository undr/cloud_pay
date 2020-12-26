# frozen_string_literal: true
require 'spec_helper'

RSpec.describe CloudPay::Kassir do
  describe '.new' do
    it { expect(CloudPay::Kassir.new).to be_instance_of(CloudPay::Kassir::Main) }
  end
end
