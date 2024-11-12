Geocoder.configure(
  lookup: :google,
  api_key: ENV["GOOGLE_API_KEY"],
  timeout: 5,
  units: :mi,
  cache: Rails.cache,
  use_https: true
)
