require 'uri'
require 'net/http'
require 'json'

class ZeroShotCategoriser
  FLASK_URL = ENV.fetch('FLASK_URL', nil)
  @uri_string = FLASK_URL+'/categoriser'
  def self.request(upload_text, all_categories)
    uri = URI(@uri_string)
    req = Net::HTTP::Post.new(uri)
    req["Content-Type"] = "application/json"
    req.body = get_body_request(upload_text, all_categories)
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout=180
    # http.use_ssl = true

    # start local
    # uri = URI("http://localhost:5001")
    # http = Net::HTTP.new(uri.host, 5001)
    # http.read_timeout=180
    # end local

    res = http.request(req)
    response_data = JSON.parse(res.body)
    category = response_data["data"]["category"]
    return { "category": category }
  end

  private

  def self.get_body_request(upload_text, all_categories)
    body_request = {
      "inputs": upload_text,
      "parameters": { "candidate_labels": all_categories }
    }.to_json
    body_request
  end
end
