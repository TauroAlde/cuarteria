class ConsultationsController < ApplicationController
  require 'httparty'

  before_action :authenticate_user!

  BASE_API_URL = 'https://api-demo.skydropx.com/v1/consignment_notes/categories'

  HEADERS = {
    'Content-Type' => 'application/json',
    'Authorization' => "Token token=k5znfOgbwdzVjZfD8JfWju4VcyM7vwMCw7jwoOYijOg"
  }

  def index

  end


  def show
    consultation_id = params[:id]
    response = HTTParty.get("#{BASE_API_URL}/#{consultation_id}", headers: HEADERS)
    if response.success?
      render json: response.parsed_response
    else
      render json: { error: 'Consultation not found' }, status: response.code
    end
  end
end
