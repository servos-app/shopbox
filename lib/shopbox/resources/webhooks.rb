module Shopbox
  module Resources
    class Webhooks < Resource
      include Listable
      include Creatable
      include Replaceable
      include Deletable
    end
  end
end
