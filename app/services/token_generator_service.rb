# app/services/token_generator_service.rb
require 'net/http'
require 'json'

class TokenGeneratorService
  API_URL = 'https://sb-app.soloenvios.com/api/v1/oauth/token'

  def initialize(client_id, client_secret)
    @client_id = client_id
    @client_secret = client_secret
  end

  def call
    response = request_token
    handle_response(response)
  end

  private

  def request_token
    uri = URI(API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
    request.body = { scope: "default", grant_type: "client_credentials", client_id: @client_id, client_secret: @client_secret }.to_json

    http.request(request)
  end

  def handle_response(response)
    if response.is_a?(Net::HTTPSuccess)
      body = JSON.parse(response.body)
      "#{body["token_type"]} #{body["access_token"]}"
    else
      raise "Error generating token: #{response.message}"
    end
  end
end
