module Shopbox
  module Resources
    class Customers < Resource
      include Listable
      include Retrievable
      include Creatable
      include Replaceable
      include Deletable

      def search(**params)
        client.get(at("search"), params: params)
      end

      def by_custom_number(custom_number)
        client.get(at("custom-number", custom_number))
      end

      def extend_credit_limit(id)
        client.get(at(id, "extend-credit-limit"))
      end

      def import(file:, filename:, content_type: "text/csv", **fields)
        multipart = Multipart.new(fields, file_field: "csv", file: file, filename: filename, content_type: content_type)
        client.upload(at("import-customers"), multipart)
      end
    end
  end
end
