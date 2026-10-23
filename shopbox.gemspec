require_relative "lib/shopbox/version"

Gem::Specification.new do |spec|
  spec.name = "shopbox"
  spec.version = Shopbox::VERSION
  spec.authors = ["SERVOS"]
  spec.email = ["a@asgerbehnckejacobsen.dk"]

  spec.summary = "Ruby client for the Shopbox POS API (v3)"
  spec.description = "A client for the Shopbox POS API v3 (docs.shopbox.com). Plain Ruby, no runtime dependencies."
  spec.homepage = "https://github.com/servos-app/shopbox"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4"

  spec.files = Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]
end
