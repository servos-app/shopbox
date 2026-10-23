module Shopbox
  module Resources
    class IntegrationAccounts < Resource
      def accounts
        client.get(at("accounts"))
      end

      def tax_codes
        client.get(at("tax-codes"))
      end
    end
  end
end
