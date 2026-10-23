require_relative "test_helper"

class ResourcesTest < Minitest::Test
  include ShopboxTestHelpers

  def test_takeaway_create_order
    @client.takeaway.create_order(cash_register: 7, staff: 3, type: 0, pickup_time: "12:00", order_type: "dinein")

    assert_request "POST", "/takeaway/order"
    assert_equal 7, last_body["cash_register"]
  end

  def test_takeaway_order_transitions
    @client.takeaway.accept_order(7, 11)
    assert_request "PUT", "/takeaway/7/accept-order/11"

    @client.takeaway.complete_order(7, 12)
    assert_request "PUT", "/takeaway/7/complete-order/12"

    @client.takeaway.decline_order(7, 13)
    assert_request "PUT", "/takeaway/7/decline-order/13"

    @client.takeaway.parked_orders(7)
    assert_request "GET", "/takeaway/7/parked-orders"
  end

  def test_basket_by_order_hash
    @client.baskets.by_order_hash("ord_abc")

    assert_request "GET", "/baskets/by-order-hash"
    assert_equal "ord_abc", last_query["orderHash"]
  end

  def test_product_by_code_uses_the_spec_path
    @client.products.by_code("5701234567890")

    assert_request "GET", "/prooducts/5701234567890/by-code"
  end

  def test_product_barcodes
    @client.products.barcodes

    assert_request "GET", "/all-barcodes"
  end

  def test_product_assign_to_filter
    @client.products.assign_to_filter(4, filter: 2, is_visible: true)

    assert_request "PUT", "/products/4/assign-to-filter"
    assert_equal "2", last_query["filter"]
    assert_equal({"is_visible" => true}, last_body)
  end

  def test_customer_import
    @client.customers.import(file: StringIO.new("Name\nAda"), filename: "customers.csv", client: 42)

    assert_request "POST", "/customers/import-customers"
    assert_includes last_request.body, %(name="csv"; filename="customers.csv")
    assert_includes last_request.body, %(name="client"\r\n\r\n42)
  end

  def test_account_update_takes_no_id
    @client.accounts.update(name: "Front desk")

    assert_request "PUT", "/accounts"
  end

  def test_account_generate_token_uses_the_spec_path
    @client.accounts.generate_token(email: "pos@example.com")

    assert_request "POST", "/acccounts/generate-token"
    assert_equal({"email" => "pos@example.com"}, last_body)
  end

  def test_yourpay_start_payment
    @client.yourpay_pax.start_payment(cash_register: 7, pax: 1, amount: 12_500)

    assert_request "POST", "/yourpay-pax/start-payment"
    assert_equal({"cash_register" => 7, "pax" => 1, "amount" => 12_500}, last_body)
  end

  def test_integration_accounts
    @client.integration_accounts.tax_codes

    assert_request "GET", "/integration-accounts/tax-codes"
  end
end
