module Shopbox
  module Resources
    class Accounts < Resource
      include Creatable

      # Updates the authenticated account; the endpoint takes no id.
      def update(body)
        client.put(path, body: body)
      end

      def pin_token(**params)
        client.get(at("pin-token"), params: params)
      end

      # Path as the Shopbox spec spells it.
      def generate_token(email:)
        client.post("/acccounts/generate-token", body: {email: email})
      end

      def change_language(id, body)
        client.put(at(id, "change-lang"), body: body)
      end
    end
  end
end
