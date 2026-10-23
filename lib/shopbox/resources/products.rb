module Shopbox
  module Resources
    class Products < Resource
      include Listable
      include Retrievable
      include Creatable
      include Replaceable

      def search(**params)
        client.get(at("search"), params: params)
      end

      # Path as the Shopbox spec spells it.
      def by_code(code)
        client.get("/prooducts/#{URI.encode_uri_component(code.to_s)}/by-code")
      end

      def barcodes
        client.get("/all-barcodes")
      end

      def units
        client.get(at("units"))
      end

      def variances(id)
        client.get(at(id, "product-variances"))
      end

      def filter_price(id)
        client.get(at(id, "filter-price"))
      end

      def assign_to_filter(id, filter:, is_visible:)
        client.put(at(id, "assign-to-filter"), params: {filter: filter}, body: {is_visible: is_visible})
      end

      def history(id, **params)
        client.get(at(id, "history"), params: params)
      end
    end
  end
end
