require "json"
require "net/http"
require "openssl"
require "securerandom"
require "uri"

require_relative "shopbox/version"
require_relative "shopbox/errors"
require_relative "shopbox/response"
require_relative "shopbox/connection"
require_relative "shopbox/multipart"
require_relative "shopbox/webhook_type"
require_relative "shopbox/resource"
Dir[File.join(__dir__, "shopbox/resources/*.rb")].each { |file| require file }
require_relative "shopbox/client"

# Ruby client for the Shopbox POS API v3, built from the spec at
# https://docs.shopbox.com/reference/shopbox-api.v1.yaml
module Shopbox
end
