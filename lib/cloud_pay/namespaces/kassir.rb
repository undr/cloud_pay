# frozen_string_literal: true
module CloudPay
  module Kassir
    extend self

    def new(*args)
      Main.new(*args)
    end
  end
end
