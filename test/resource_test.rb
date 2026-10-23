require_relative "test_helper"

class ResourceTest < Minitest::Test
  include ShopboxTestHelpers

  def test_list
    @client.webhooks.list(sort: "name")

    assert_request "GET", "/webhooks"
    assert_equal "name", last_query["sort"]
  end

  def test_retrieve
    @client.modifier_groups.retrieve(9, filter: "active")

    assert_request "GET", "/modifiers-groups/9"
    assert_equal "active", last_query["filter"]
  end

  def test_create
    @client.webhooks.create(name: "Baskets", client: 42, url: "https://servos.test/shopbox", type: Shopbox::WebhookType::CREATE_BASKET)

    assert_request "POST", "/webhooks"
    assert_equal 1, last_body["type"]
  end

  def test_update
    @client.customers.update(5, name: "Ada")

    assert_request "PUT", "/customers/5"
    assert_equal({"name" => "Ada"}, last_body)
  end

  def test_delete
    @client.modifiers.delete(3)

    assert_request "DELETE", "/modifiers/3"
    assert_nil last_request.body
  end

  def test_escapes_path_segments
    @client.customers.by_custom_number("A/B 1")

    assert_equal "/api/v3/customers/custom-number/A%2FB%201", last_request.uri.path
  end

  def test_collections_list
    @client.staff.list

    assert_request "GET", "/staff"
  end

  def test_resources_are_memoized
    assert_same @client.products, @client.products
  end
end
