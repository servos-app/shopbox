module Shopbox
  module Resources
    class DiscountGroups < Resource
      include Listable
      include Retrievable
      include Creatable
      include Replaceable
    end
  end
end
