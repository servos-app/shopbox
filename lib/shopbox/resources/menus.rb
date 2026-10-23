module Shopbox
  module Resources
    class Menus < Resource
      include Listable
      include Creatable
      include Replaceable
    end
  end
end
