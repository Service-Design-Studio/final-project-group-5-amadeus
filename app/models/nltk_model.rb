require 'uri'
require 'net/http'
require 'json'

class NLTK_Model
  @uri_string = 'https://asia-southeast1-amadeus-2000.cloudfunctions.net/nltk_model'

  def self.request(upload_text)
    uri = URI(@uri_string)
    req = Net::HTTP::Post.new(uri)
    req["Content-Type"] = "application/json"
    req.body = get_body_request(upload_text)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    res =  http.request(req)
    response_data = JSON.parse(res.body)
    summary = response_data["summary"]
    topics = response_data["topics"]
    return { "summary": summary, "topics": topics}
  end

  private
  def self.get_body_request(upload_text)
    body_request = {
      "upload": {
        "upload_text": upload_text,
        "replace_dict": {
          "US": "USA", "U.S": "USA", "United States": "USA" },
        "num_topic": "7",
        "summary_threshold": "1.3" }
    }.to_json
  end
end
