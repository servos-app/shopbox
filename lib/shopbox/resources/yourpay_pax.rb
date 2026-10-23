module Shopbox
  module Resources
    # Card terminals (PAX devices) paired through Yourpay.
    class YourpayPax < Resource
      def start_payment(cash_register:, pax:, amount:)
        client.post(at("start-payment"), body: {cash_register: cash_register, pax: pax, amount: amount})
      end

      def pax(cash_register)
        client.get(at(cash_register, "get-pax"))
      end
    end
  end
end
