class QuotationsController < ApplicationController
  require 'net/http'
  require 'uri'
  require 'json'

  before_action :authenticate_user!
  before_action :soloenvios_setting

  def index
    @user = current_user
  end

  def show
    @get_quotatoin_response = JSON.parse(get_quotation(params["quotation_id"]).body)

    while !@get_quotatoin_response["is_completed"] do
      @get_quotatoin_response = JSON.parse(get_quotation(params["quotation_id"]).body)
    end
  end

  def new
    new_quotation_response = new_quotation(quotation_params)
    if new_quotation_response.code == "401"
      new_quotation_response = generate_token
    end

    if ["422", "400"].include?(new_quotation_response.code)
      quotation_errors(new_quotation_response.body)
      redirect_to quotations_path and return
    end

    quotation = JSON.parse(new_quotation_response.body)

    if quotation
      quotation_id = quotation["id"]
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
    request['Authorization'] = soloenvios_setting.token
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
    request['Authorization'] = "Bearer #{soloenvios_setting.token}"

    response = http.request(request)
  end

  def soloenvios_setting
    @soloenvios_setting ||= current_user.settings.find_by_app_name("Soloenvios")
  end

  def verify_token
    FetchVerifyTokenLifeJob.perform_later(soloenvios_setting.id)
  end

  def generate_token
    token_generator = TokenGeneratorService.new(@soloenvios_setting.api_key, @soloenvios_setting.secret_key)
    @soloenvios_setting.update(token: token_generator.call.split.last)

    new_quotation(quotation_params)
  end

  def quotation_errors(response)
    flash[:alert] = "Error generating quotation: #{JSON.parse(response)['errors'].map { |k, v| v.map { |error| "#{k}: #{error}" }.join(', ') }.join(', ')}"
  end
end
