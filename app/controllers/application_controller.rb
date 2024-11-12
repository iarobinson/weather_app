class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  def index
    zip_code = params[:address]
    cached_data = Rails.cache.read("weather_data_#{zip_code}")
  
    if cached_data
      @weather_data = cached_data
    else
      @weather_data = NoaaDataFetchJob.perform_now(zip_code)
      Rails.cache.write("weather_data_#{zip_code}", @weather_data)
    end
    render 'pages/index'
  end
  
  private

    def weather_query_params
      params.permit(:address)
    end
end
