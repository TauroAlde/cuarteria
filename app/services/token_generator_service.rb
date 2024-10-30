# app/services/token_generator_service.rb
require 'net/http'
require 'json'

class TokenGeneratorService
  API_URL = 'https://app.soloenvios.com/api/v1/oauth/token'

  def initialize(client_id, client_secret)
    @client_id = client_id
    @client_secret = client_secret
    @user_setting = user_setting
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
    request.body = { client_id: @client_id, client_secret: @client_secret }.to_json

    http.request(request)
  end

  def handle_response(response)
    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)['token']
    else
      raise "Error generating token: #{response.message}"
    end
  end
end
