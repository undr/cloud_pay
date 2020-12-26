# frozen_string_literal: true
require 'spec_helper'

RSpec.describe CloudPay::Payments do
  describe '.new' do
    it { expect(CloudPay::Payments.new).to be_instance_of(CloudPay::Payments::Main) }
  end
end
