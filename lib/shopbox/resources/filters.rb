module Shopbox
  module Resources
    class Filters < Resource
      include Listable

      def catalog(**params)
        client.get(at("catalog"), params: params)
      end
    end
  end
end
