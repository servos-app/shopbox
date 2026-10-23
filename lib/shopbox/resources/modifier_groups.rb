module Shopbox
  module Resources
    class ModifierGroups < Resource
      include Listable
      include Retrievable
      include Creatable
      include Replaceable
      include Deletable
    end
  end
end
