module Shopbox
  module Connection
    # Errors name the host only: the access token travels in the query string.
    def self.perform(request, timeout:, open_timeout:)
      uri = request.uri

      Net::HTTP.start(
        uri.host, uri.port,
        use_ssl: uri.scheme == "https", read_timeout: timeout, open_timeout: open_timeout
      ) do |http|
        response = http.request(request)
        Response.new(status: response.code.to_i, body: response.body.to_s)
      end
    rescue Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::EHOSTUNREACH, Errno::ETIMEDOUT, EOFError, SocketError,
      OpenSSL::SSL::SSLError => error
      raise Errors::ConnectionError, "Connection to #{uri.host} failed: #{error.class}"
    rescue Net::OpenTimeout, Net::ReadTimeout, Net::WriteTimeout => error
      raise Errors::TimeoutError, "#{error.class} talking to #{uri.host}"
    end
  end
end
