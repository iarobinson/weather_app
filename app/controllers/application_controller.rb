class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  def index
    user_input = params[:user_input]
    cached_data = Rails.cache.read("weather_data_#{user_input}")
    binding.pry
    if cached_data
      @weather_data = cached_data
    else
      @weather_data = NoaaDataFetchJob.perform_now(user_input)
    end
    render 'pages/index'
  end
  
  private

    def weather_query_params
      params.permit(:user_input)
    end
end
