module Shopbox
  # Encoded up front rather than with Net::HTTP#set_form, so the body can be
  # inspected before it is sent.
  class Multipart
    def initialize(fields, file_field:, file:, filename:, content_type: "application/octet-stream")
      @fields = fields.compact
      @file_field = file_field
      @file = file
      @filename = filename.to_s.delete("\r\n").gsub('"', "%22")
      @file_content_type = content_type
      @boundary = "shopbox-#{SecureRandom.hex(16)}"
    end

    def content_type
      "multipart/form-data; boundary=#{@boundary}"
    end

    def body
      @body ||= begin
        parts = @fields.map { |name, value| part(%(name="#{name}"), value.to_s) }
        parts << part(%(name="#{@file_field}"; filename="#{@filename}"), @file.read, type: @file_content_type)
        (parts.join + "--#{@boundary}--\r\n").b
      end
    end

    private

    def part(disposition, content, type: nil)
      headers = ["Content-Disposition: form-data; #{disposition}", ("Content-Type: #{type}" if type)].compact
      "--#{@boundary}\r\n#{headers.join("\r\n")}\r\n\r\n".b + content.b + "\r\n"
    end
  end
end
