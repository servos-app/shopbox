require_relative "test_helper"

class MultipartTest < Minitest::Test
  def test_encodes_fields_and_the_file
    multipart = Shopbox::Multipart.new(
      {client: 42, name: "Name", phone: nil},
      file_field: "csv", file: StringIO.new("Name\nAda"), filename: "customers.csv", content_type: "text/csv"
    )
    boundary = multipart.content_type[/boundary=(.+)\z/, 1]

    expected = "--#{boundary}\r\nContent-Disposition: form-data; name=\"client\"\r\n\r\n42\r\n" \
      "--#{boundary}\r\nContent-Disposition: form-data; name=\"name\"\r\n\r\nName\r\n" \
      "--#{boundary}\r\nContent-Disposition: form-data; name=\"csv\"; filename=\"customers.csv\"\r\n" \
      "Content-Type: text/csv\r\n\r\nName\nAda\r\n--#{boundary}--\r\n"
    assert_equal expected.b, multipart.body
  end

  def test_filename_cannot_break_the_header
    filename = "kunder \"2026\"\r\n.csv"
    multipart = Shopbox::Multipart.new({}, file_field: "csv", file: StringIO.new(""), filename: filename)

    assert_includes multipart.body, %(filename="kunder %222026%22.csv"\r\n)
  end
end
