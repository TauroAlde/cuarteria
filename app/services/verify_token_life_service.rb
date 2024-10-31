# app/services/verify_token_life_service.rb
require 'net/http'
require 'json'

class VerifyTokenLifeService
  API_URL = 'https://sb-app.soloenvios.com/api/v1/oauth/introspect'

  def initialize(client_id, client_secret, client_token)
    @client_id = client_id
    @client_secret = client_secret
    @client_token = client_token
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
    request.body = {
      client_id: @client_id,
      client_secret: @client_secret,
      token: @client_token,
      token_type_hint: "access_token"
    }.to_json

    http.request(request)
  end

  def handle_response(response)
    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)["active"]
    else
      raise "Error generating token: #{response.message}"
    end
  end
end
