module Shopbox
  module Resources
    class Takeaway < Resource
      def create_order(body)
        client.post(at("order"), body: body)
      end

      def parked_orders(cash_register)
        client.get(at(cash_register, "parked-orders"))
      end

      def accepted_orders(cash_register)
        client.get(at(cash_register, "accepted-orders"))
      end

      def completed_orders(cash_register)
        client.get(at(cash_register, "completed-orders"))
      end

      def accept_order(cash_register, table_basket)
        client.put(at(cash_register, "accept-order", table_basket))
      end

      def complete_order(cash_register, basket)
        client.put(at(cash_register, "complete-order", basket))
      end

      def decline_order(cash_register, table_basket)
        client.put(at(cash_register, "decline-order", table_basket))
      end
    end
  end
end
