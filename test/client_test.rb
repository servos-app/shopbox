require_relative "test_helper"

class ClientTest < Minitest::Test
  include ShopboxTestHelpers

  def test_sends_the_access_token_and_client_in_the_query
    @client.get("/staff", params: {sort: "name"})

    assert_equal "api-dev.shopbox.com", last_request.uri.host
    assert_request "GET", "/staff"
    assert_equal({"accessToken" => "token", "client" => "42", "sort" => "name"}, last_query)
    assert_equal "application/json", last_request["Accept"]
  end

  def test_live_uses_the_production_host
    client = Shopbox::Client.new(access_token: "token", live: true, connection: @connection)

    client.get("/staff")

    assert_equal "api.shopbox.com", last_request.uri.host
    assert_equal({"accessToken" => "token"}, last_query)
  end

  def test_posts_json
    @client.post("/tags", body: {name: "Drinks"})

    assert_equal "application/json", last_request["Content-Type"]
    assert_equal({"name" => "Drinks"}, last_body)
  end

  def test_raises_by_status_without_the_token_or_query_in_the_message
    @connection.respond_with(status: 422, body: {message: "The name field is required."})

    error = assert_raises(Shopbox::Errors::ValidationError) { @client.post("/customers", body: {}) }

    assert_equal "Shopbox responded 422 to POST /customers", error.message
    assert_equal 422, error.status
    assert_equal "The name field is required.", error.api_message
  end

  def test_unmapped_statuses
    assert_equal Shopbox::Errors::ServerError, Shopbox::Errors.for_status(503)
    assert_equal Shopbox::Errors::Error, Shopbox::Errors.for_status(409)
  end

  def test_paginate_follows_pages
    @connection
      .respond_with(body: {data: [{id: 1}], meta: {pagination: {current_page: 1, total_pages: 2}}})
      .respond_with(body: {data: [{id: 2}], meta: {pagination: {current_page: 2, total_pages: 2}}})

    ids = @client.paginate("/customers", params: {sort: "name"}).map { |customer| customer["id"] }

    assert_equal [1, 2], ids
    assert_equal({"page" => "2", "per-page" => "100", "sort" => "name"}, last_query.slice("page", "per-page", "sort"))
  end

  def test_paginate_stops_after_an_unpaginated_list
    @connection.respond_with(body: [{id: 1}, {id: 2}])

    assert_equal 2, @client.paginate("/countries").count
    assert_equal 1, @connection.requests.size
  end

  def test_authenticate_returns_a_client_holding_the_token
    @connection.respond_with(status: 201, body: {accessToken: "fresh", account: {id: 5}})

    client = Shopbox::Client.authenticate(
      username: "pos@example.com", password: "secret", client_id: 42, connection: @connection
    )

    assert_request "POST", "/authenticate/credentials"
    assert_equal({"username" => "pos@example.com", "password" => "secret"}, last_body)
    refute last_query.key?("accessToken")
    assert_equal "fresh", client.access_token
    assert_equal 42, client.client_id
  end

  def test_authenticate_raises_without_a_token
    @connection.respond_with(status: 201, body: {}).respond_with(status: 201, body: "")

    2.times do
      assert_raises(Shopbox::Errors::AuthenticationError) do
        Shopbox::Client.authenticate(username: "pos@example.com", password: "secret", connection: @connection)
      end
    end
  end

  def test_rejects_unknown_options
    assert_raises(ArgumentError) { Shopbox::Client.new(access_token: "token", client: 42) }
  end

  def test_upload_sends_multipart
    multipart = Shopbox::Multipart.new({}, file_field: "csv", file: StringIO.new("a,b"), filename: "c.csv")

    @client.upload("/customers/import-customers", multipart)

    assert_equal multipart.content_type, last_request["Content-Type"]
    assert_equal multipart.body, last_request.body
  end

  def test_connection_failures_name_the_host_only
    request = Net::HTTP::Get.new(URI("http://127.0.0.1:1/api/v3/staff?accessToken=secret"))

    error = assert_raises(Shopbox::Errors::ConnectionError) do
      Shopbox::Connection.perform(request, timeout: 1, open_timeout: 1)
    end

    refute_includes error.message, "secret"
  end
end
