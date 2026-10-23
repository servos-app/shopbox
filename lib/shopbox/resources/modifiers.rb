module Shopbox
  module Resources
    class Modifiers < Resource
      include Listable
      include Retrievable
      include Creatable
      include Replaceable
      include Deletable
    end
  end
end
