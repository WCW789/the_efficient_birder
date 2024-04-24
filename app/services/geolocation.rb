class Geolocation
  def initialize(address_params)
    @address_params = address_params
  end

  def mapping
    address = CGI.escape(@address_params)

    url = URI("https://api.mapbox.com/geocoding/v5/mapbox.places/#{address}.json?access_token=#{ENV['MAPBOX']}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url)
    response = http.request(request)

    if response.code == "200"
      response_body = JSON.parse(response.body)
      center = response_body["features"].first["center"]
    else
      puts "Error"
    end
  end
end
