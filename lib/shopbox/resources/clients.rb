module Shopbox
  module Resources
    class Clients < Resource
      include Listable
      include Creatable

      def create_company(body = nil)
        client.post(at("create-company"), body: body)
      end
    end
  end
end
