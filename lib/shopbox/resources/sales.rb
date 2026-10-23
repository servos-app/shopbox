module Shopbox
  module Resources
    class Sales < Resource
      include Listable
      include Retrievable
    end
  end
end
