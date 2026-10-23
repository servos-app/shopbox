module Shopbox
  class Response
    attr_reader :status, :data

    def initialize(status:, body:)
      @status = status
      @data = parse(body)
    end

    def success?
      status.between?(200, 299)
    end

    def items
      data.is_a?(Hash) ? Array(data["data"]) : Array(data)
    end

    def current_page
      pagination&.dig("current_page")
    end

    def total_pages
      pagination&.dig("total_pages")
    end

    def last_page?
      current_page.nil? || total_pages.nil? || current_page >= total_pages
    end

    def error_message
      case data
      when Hash then data["message"] || data["error"]
      when String then data unless data.empty?
      end
    end

    private

    def pagination
      data.dig("meta", "pagination") if data.is_a?(Hash)
    end

    def parse(body)
      return if body.nil? || body.empty?

      JSON.parse(body)
    rescue JSON::ParserError
      body
    end
  end
end
