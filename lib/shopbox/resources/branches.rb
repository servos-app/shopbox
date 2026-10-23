module Shopbox
  module Resources
    class Branches < Resource
      include Listable
      include Retrievable

      def your_pay(id)
        client.get(at(id, "your-pay"))
      end
    end
  end
end
