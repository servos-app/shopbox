module Shopbox
  class Resource
    module Listable
      def list(**params)
        client.get(path, params: params)
      end

      def paginate(**params)
        client.paginate(path, params: params)
      end
    end

    module Retrievable
      def retrieve(id, **params)
        client.get(at(id), params: params)
      end
    end

    module Creatable
      def create(body)
        client.post(path, body: body)
      end
    end

    module Replaceable
      def update(id, body)
        client.put(at(id), body: body)
      end
    end

    module Deletable
      def delete(id)
        client.delete(at(id))
      end
    end

    attr_reader :client, :path

    def initialize(client, path)
      @client = client
      @path = path
    end

    private

    def at(*segments)
      [path, *segments.map { |segment| URI.encode_uri_component(segment.to_s) }].join("/")
    end
  end
end
