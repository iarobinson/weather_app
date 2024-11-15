require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "should get index and cache weather data" do
    user_input = "89502"
    cache_key = "user_input_#{user_input}"
    
    # Simulate the first request where the data is not cached yet
    Rails.cache.clear
    get root_url, params: { user_input: user_input }

    assert_response :success
    assert_not_nil assigns(:weather_data)  # Ensure weather_data is assigned

    # Check that the weather data is cached
    cached_data = Rails.cache.read(cache_key)
    assert_not_nil cached_data  # Ensure the data is cached
  end

  test "should return cached weather data if available" do
    user_input = "89521"
    cache_key = "user_input_#{user_input}"
    
    # Simulate caching data
    cached_weather_data = { temperature: 75, conditions: "Sunny" }
    Rails.cache.write(cache_key, cached_weather_data)

    # Simulate a request where the data should be served from cache
    get root_url, params: { user_input: user_input }

    assert_response :success
    assert_equal cached_weather_data, assigns(:weather_data)  # Ensure cached data is used
  end
end
