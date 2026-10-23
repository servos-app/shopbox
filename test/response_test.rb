require_relative "test_helper"

class ResponseTest < Minitest::Test
  def test_items_unwrap_the_data_envelope
    response = Shopbox::Response.new(status: 200, body: {data: [{id: 1}]}.to_json)

    assert_equal [{"id" => 1}], response.items
  end

  def test_items_of_a_record_without_the_envelope
    assert_empty Shopbox::Response.new(status: 200, body: {id: 1}.to_json).items
  end

  def test_error_message_falls_back_to_error
    response = Shopbox::Response.new(status: 401, body: {error: "Unauthenticated"}.to_json)

    assert_equal "Unauthenticated", response.error_message
  end

  def test_last_page
    paginated = ->(current, total) { {meta: {pagination: {current_page: current, total_pages: total}}}.to_json }

    refute Shopbox::Response.new(status: 200, body: paginated.call(1, 3)).last_page?
    assert Shopbox::Response.new(status: 200, body: paginated.call(3, 3)).last_page?
    assert Shopbox::Response.new(status: 200, body: {id: 1}.to_json).last_page?
  end

  def test_keeps_a_body_that_is_not_json
    response = Shopbox::Response.new(status: 500, body: "Server Error")

    assert_equal "Server Error", response.data
    assert_equal "Server Error", response.error_message
  end

  def test_empty_body
    response = Shopbox::Response.new(status: 204, body: "")

    assert_nil response.data
    assert_empty response.items
    assert_nil response.error_message
  end
end
