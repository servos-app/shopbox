module Shopbox
  module Resources
    class Baskets < Resource
      include Listable
      include Retrievable
      include Creatable

      def by_order_hash(order_hash)
        client.get(at("by-order-hash"), params: {orderHash: order_hash})
      end

      def top_tag_sales(**params)
        client.get(at("top-tag-sales"), params: params)
      end

      def top_item_sales(**params)
        client.get(at("top-item-sales"), params: params)
      end

      def top_staff(**params)
        client.get(at("top-staff"), params: params)
      end

      def compare_staff(**params)
        client.get(at("compare-staff"), params: params)
      end

      def payment_types(**params)
        client.get(at("payment-types"), params: params)
      end

      def dashboard(**params)
        client.get(at("dashboard"), params: params)
      end
    end
  end
end
