module Shopbox
  # One client per Shopbox account and selected client (shop). Talks to the
  # dev host unless `live: true`.
  #
  #   client = Shopbox::Client.authenticate(username: "pos@example.com", password: "…", client_id: 42, live: true)
  #   client.access_token # store it and pass it to Client.new next time
  #   client.products.paginate(sort: "name").to_a
  #   client.takeaway.create_order(cash_register: 7, staff: 3, type: 0, pickup_time: "12:00", order_type: "dinein")
  class Client
    LIVE_URL = "https://api.shopbox.com/api/v3".freeze
    TEST_URL = "https://api-dev.shopbox.com/api/v3".freeze
    AUTHENTICATION_PATH = "/authenticate/credentials".freeze
    PAGE_SIZE = 100

    RESOURCES = {
      accounts: [Resources::Accounts, "/accounts"],
      baskets: [Resources::Baskets, "/baskets"],
      branches: [Resources::Branches, "/branches"],
      cash_registers: [Resources::CashRegisters, "/cash-registers"],
      clients: [Resources::Clients, "/clients"],
      customers: [Resources::Customers, "/customers"],
      discount_groups: [Resources::DiscountGroups, "/discount-groups"],
      filters: [Resources::Filters, "/filters"],
      integration_accounts: [Resources::IntegrationAccounts, "/integration-accounts"],
      menus: [Resources::Menus, "/menus"],
      modifier_groups: [Resources::ModifierGroups, "/modifiers-groups"],
      modifiers: [Resources::Modifiers, "/modifiers"],
      payment_types: [Resources::PaymentTypes, "/payment-types"],
      products: [Resources::Products, "/products"],
      rooms: [Resources::Rooms, "/rooms"],
      sales: [Resources::Sales, "/sales"],
      tables: [Resources::Tables, "/tables"],
      tags: [Resources::Tags, "/tags"],
      takeaway: [Resources::Takeaway, "/takeaway"],
      taxes: [Resources::Taxes, "/taxes"],
      webhooks: [Resources::Webhooks, "/webhooks"],
      yourpay_pax: [Resources::YourpayPax, "/yourpay-pax"],

      coupons: [Resources::Collection, "/coupons"],
      counter_items: [Resources::Collection, "/counter-items"],
      countries: [Resources::Collection, "/countries"],
      currencies: [Resources::Collection, "/currencies"],
      device_tokens: [Resources::Collection, "/device-tokens"],
      discount_reasons: [Resources::Collection, "/discount-reasons"],
      expense_reasons: [Resources::Collection, "/expense-reasons"],
      expenses: [Resources::Collection, "/expenses"],
      images: [Resources::Collection, "/images"],
      inventory_warning_emails: [Resources::Collection, "/inventory-warning-emails"],
      journal: [Resources::Collection, "/journal"],
      payment_type_settings: [Resources::Collection, "/payment-types-settings"],
      planday_departments: [Resources::Collection, "/planday-departments"],
      printer_groups: [Resources::Collection, "/printer-groups"],
      product_inventories: [Resources::Collection, "/product-inventories"],
      product_variances: [Resources::Collection, "/product-variances"],
      reports: [Resources::Collection, "/reports"],
      roles: [Resources::Collection, "/roles"],
      staff: [Resources::Collection, "/staff"],
      time_zones: [Resources::Collection, "/time-zones"],
      variance_values: [Resources::Collection, "/variance-value"]
    }.freeze

    RESOURCES.each do |name, (resource_class, path)|
      define_method(name) { @resources[name] ||= resource_class.new(self, path) }
    end

    def self.authenticate(username:, password:, **options)
      response = new(**options).post(AUTHENTICATION_PATH, body: {username: username, password: password})
      access_token = response.data["accessToken"] if response.data.is_a?(Hash)
      raise Errors::AuthenticationError.new("Shopbox returned no access token", response: response) unless access_token

      new(access_token: access_token, **options)
    end

    attr_reader :access_token, :client_id

    def initialize(
      access_token: nil, client_id: nil, live: false, timeout: 30, open_timeout: 10, connection: Connection
    )
      @access_token = access_token
      @client_id = client_id
      @base_url = live ? LIVE_URL : TEST_URL
      @timeouts = {timeout: timeout, open_timeout: open_timeout}
      @connection = connection
      @resources = {}
    end

    def get(path, params: {})
      request(Net::HTTP::Get, path, params: params)
    end

    def post(path, body: nil, params: {})
      request(Net::HTTP::Post, path, params: params, body: body)
    end

    def put(path, body: nil, params: {})
      request(Net::HTTP::Put, path, params: params, body: body)
    end

    def delete(path, params: {})
      request(Net::HTTP::Delete, path, params: params)
    end

    def upload(path, multipart, params: {})
      request(Net::HTTP::Post, path, params: params) do |http_request|
        http_request["Content-Type"] = multipart.content_type
        http_request.body = multipart.body
      end
    end

    def paginate(path, params: {})
      Enumerator.new do |items|
        page = 1

        loop do
          response = get(path, params: params.merge(page: page, "per-page": PAGE_SIZE))
          response.items.each { |item| items << item }
          break if response.last_page?

          page += 1
        end
      end
    end

    private

    def request(type, path, params:, body: nil)
      http_request = build_request(type, uri(path, params), body)
      yield http_request if block_given?

      response = @connection.perform(http_request, **@timeouts)
      return response if response.success?

      message = "Shopbox responded #{response.status} to #{type::METHOD} #{path}"
      raise Errors.for_status(response.status).new(message, response: response)
    end

    def build_request(type, uri, body)
      http_request = type.new(uri)
      http_request["Accept"] = "application/json"

      unless body.nil?
        http_request["Content-Type"] = "application/json"
        http_request.body = body.to_json
      end

      http_request
    end

    def uri(path, params)
      uri = URI("#{@base_url}#{path}")
      query = {accessToken: @access_token, client: @client_id}.merge(params).compact
      uri.query = URI.encode_www_form(query) if query.any?
      uri
    end
  end
end
