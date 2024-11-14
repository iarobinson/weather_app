class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  def index
    user_input = params[:user_input]
    cache_key = "user_input_#{user_input}"
    cached_data = Rails.cache.read(cache_key)
  
    if cached_data
      @weather_data = cached_data
    else
      @weather_data = NoaaDataFetchJob.perform_now(user_input)
      Rails.cache.write(cache_key, @weather_data, expires_in: 30.minutes)
    end
    render 'pages/index'
  end
  
  private

    def weather_query_params
      params.permit(:user_input)
    end
end
