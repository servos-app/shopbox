require "minitest/autorun"
require "stringio"
require_relative "../lib/shopbox"

class FakeConnection
  attr_reader :requests

  def initialize
    @requests = []
    @responses = []
  end

  def respond_with(status: 200, body: {})
    @responses << Shopbox::Response.new(status: status, body: body.is_a?(String) ? body : body.to_json)
    self
  end

  def perform(request, timeout:, open_timeout:)
    @requests << request
    @responses.shift || Shopbox::Response.new(status: 200, body: "{}")
  end

  def last_request = requests.last
end

module ShopboxTestHelpers
  def setup
    @connection = FakeConnection.new
    @client = Shopbox::Client.new(access_token: "token", client_id: 42, connection: @connection)
  end

  def last_request = @connection.last_request

  def last_query = URI.decode_www_form(last_request.uri.query.to_s).to_h

  def last_body = JSON.parse(last_request.body)

  def assert_request(method, path)
    assert_equal method, last_request.method
    assert_equal "/api/v3#{path}", last_request.uri.path
  end
end
