# frozen_string_literal: true
module CloudPay
  module Payments
    extend self

    def new(*args)
      Main.new(*args)
    end
  end
end
