class QuotationsController < ApplicationController
  before_action :authenticate_user!

  require 'net/http'
  require 'uri'
  require 'json'

  TOKEN = 'Bearer MqTuDi74uTs9XviMe7ipPvlfYnyk8y2Qb7xwSlj4lIM'


  def index
    @user = current_user
  end

  def show
    binding.pry
    @get_quotatoin_response = JSON.parse(get_quotation(params["quotation_id"]).body)

    while !@get_quotatoin_response["is_completed"] do
      @get_quotatoin_response = JSON.parse(get_quotation(quotation_id).body)
    end

    flash[:notice] = "Quotation successfully generated."
    @get_quotatoin_response
  end

  def new
    quotation_response = new_quotation(quotation_params)

    # if quotation_response.code == "401"

    if quotation_response.code == "422" ||  quotation_response.code == "400"
      flash[:alert] = "Error generating quotation: #{response['errors'].map { |k, v| v.map { |error| "#{k}: #{error}" }.join(', ') }.join(', ')}"
      redirect_to quotations_path
    end

    response = JSON.parse(quotation_response.body)


    if response
      quotation_id = response["id"]
      flash[:notice] = "Quotation successfully generated."
      redirect_to quotation_path(current_user.id, quotation_id: quotation_id)
    else
      flash[:alert] = "Failed to generate quotation after multiple attempts."
      redirect_to quotation_path(current_user.id)
    end
  end

  private

  def quotation_params
    params.require(:quotation).permit(address_from: address_params, address_to: address_params, parcels: parcels_params)
  end

  def address_params
    [
      :address_from,
      :country_code,
      :postal_code,
      :area_level1,
      :area_level2,
      :area_level3,
      :street1,
      :apartment_number,
      :reference,
      :name,
      :company,
      :phone,
      :email
    ]
  end

  def parcels_params
    [
      :length,
      :width,
      :height,
      :weight,
      :quantity
    ]
  end

  def new_quotation(quotation)
    uri = URI('https://sb-app.soloenvios.com/api/v1/quotations')

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['Authorization'] = TOKEN
    request.body = {
      "quotation": {
        "address_from": {
          "country_code": "mx",
          "postal_code": quotation_params["address_from"]['postal_code'],
          "area_level1": quotation_params["address_from"]["area_level1"],
          "area_level2": quotation_params["address_from"]["area_level2"],
          "area_level3": quotation_params["address_from"]["area_level3"],
          "street1": quotation_params["address_from"]["street1"],
          "apartment_number": quotation_params["address_from"]["apartment_number"],
          "reference": quotation_params["address_from"]["reference"],
          "name": quotation_params["address_from"]["name"],
          "company": quotation_params["address_from"]["company"],
          "phone": quotation_params["address_from"]["phone"],
          "email": quotation_params["address_from"]["email"]
        },
        "address_to": {
          "country_code": "mx",
          "postal_code":  quotation_params["address_to"]['postal_code'],
          "area_level1": quotation_params["address_to"]["area_level1"],
          "area_level2": quotation_params["address_to"]["area_level2"],
          "area_level3": quotation_params["address_to"]["area_level3"],
          "street1": quotation_params["address_to"]["street1"],
          "apartment_number": quotation_params["address_to"]["apartment_number"],
          "reference": quotation_params["address_to"]["reference"],
          "name": quotation_params["address_to"]["name"],
          "company": quotation_params["address_to"]["company"],
          "phone": quotation_params["address_to"]["phone"],
          "email": quotation_params["address_to"]["email"]
        },
        "parcel": {
          "length": quotation_params["parcels"]['length'],
          "width": quotation_params["parcels"]['width'],
          "height": quotation_params["parcels"]['height'],
          "weight": quotation_params["parcels"]['weight']
        },
        "requested_carriers": [ ]
      }
    }.to_json

    response = http.request(request)
  end

  def get_quotation(id)
    require 'net/http'
    require 'uri'
    require 'json'

    uri = URI("https://sb-app.soloenvios.com/api/v1/quotations/#{id}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'

    request = Net::HTTP::Get.new(uri)
    request['Content-Type'] = 'application/json'
    request['Authorization'] = TOKEN


    response = http.request(request)
  end

end