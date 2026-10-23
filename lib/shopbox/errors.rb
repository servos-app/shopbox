module Shopbox
  module Errors
    class Error < StandardError
      attr_reader :response

      def initialize(message = nil, response: nil)
        @response = response
        super(message)
      end

      def status
        response&.status
      end

      # Kept out of #message: Shopbox's wording can echo customer data, and
      # exception messages reach error trackers.
      def api_message
        response&.error_message
      end
    end

    class ConnectionError < Error; end

    class TimeoutError < Error; end

    class BadRequestError < Error; end

    class AuthenticationError < Error; end

    class ForbiddenError < Error; end

    class NotFoundError < Error; end

    class ValidationError < Error; end

    class RateLimitError < Error; end

    class ServerError < Error; end

    BY_STATUS = {
      400 => BadRequestError,
      401 => AuthenticationError,
      403 => ForbiddenError,
      404 => NotFoundError,
      422 => ValidationError,
      429 => RateLimitError
    }.freeze

    def self.for_status(status)
      BY_STATUS.fetch(status) { (status >= 500) ? ServerError : Error }
    end
  end
end
