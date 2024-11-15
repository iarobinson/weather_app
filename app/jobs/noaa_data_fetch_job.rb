require 'net/http'
require 'json'
require 'uri'
require 'excon'

class NoaaDataFetchJob < ApplicationJob
  queue_as :default

  def perform(user_input)
    location_data = convert_user_input_to_lat_long(user_input)
    return "Invalid user input" if location_data[:error_message]
    
    p "---------- FETCHING LOCATION FROM WEATHER.GOV ----------"
    api_url = "https://api.weather.gov/points/#{location_data[:latitude].round(4)},#{location_data[:longitude].round(4)}"
    response = Excon.get(api_url, retry_limit: 3, onnect_timeout: 10, read_timeout: 10)
    parsed_data = JSON.parse(response.body)
  
    p "---------- FETCHING FORECAST FROM WEATHER.GOV ----------"
    forecast_api_endpoint = parsed_data['properties']['forecast']
    forecast_response = Excon.get(forecast_api_endpoint, retry_limit: 3, connect_timeout: 10, read_timeout: 10)
    parsed_zone_response_data = JSON.parse(forecast_response.body)
    
    location_data[:weather] = parsed_zone_response_data["properties"]["periods"]
    location_data
  end

  def convert_user_input_to_lat_long(user_input)
    results = Geocoder.search(user_input).first
    if results.class == Geocoder::Result::Google
      zip_code = results.address_components.find { |component| component["types"].include?("postal_code") }&.dig("long_name")
      return { latitude: results.latitude, longitude: results.longitude, zip_code: zip_code }
    else
      p "---------- GEOCODER DID NOT PARSE STRING ----------"
      Rails.logger.error "Something went wrong with the Geocoding #{user_input}"
      { error_message: "Geocoder did not find the way to zen" }
    end
  end
end
