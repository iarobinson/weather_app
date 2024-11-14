require 'net/http'
require 'json'
require 'uri'
require 'excon'

class NoaaDataFetchJob < ApplicationJob
  queue_as :default

  def perform(user_input)
    lat, long = convert_user_input_to_lat_long(user_input)
    return "Invalid Zip Code" if lat == true
    
    p "---------- FETCHING LOCATION FROM WEATHER.GOV ----------"
    api_url = "https://api.weather.gov/points/#{lat.round(4)},#{long.round(4)}"
    response = Excon.get(api_url, retry_limit: 3, onnect_timeout: 10, read_timeout: 10)
    parsed_data = JSON.parse(response.body)
    
    p "---------- FETCHING FORECAST FROM WEATHER.GOV ----------"
    forecast_api_endpoint = parsed_data['properties']['forecast']
    forecast_response = Excon.get(forecast_api_endpoint, retry_limit: 3, connect_timeout: 10, read_timeout: 10)
    parsed_zone_response_data = JSON.parse(forecast_response.body)

    parsed_zone_response_data["properties"]["periods"]
  end

  def convert_user_input_to_lat_long(user_input)
    binding.pry
    results = Geocoder.search(user_input).first
    if results.class == Geocoder::Result::Google
      return [results.latitude, results.longitude]
    else
      Rails.logger.error "Something went wrong with the Geocoding zip code conversion for #{user_input}"
    end
  end
end
