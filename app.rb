require 'yelp'
require 'sinatra'
require 'uber'
require 'json'
require 'httparty'
require 'google/api_client'
require 'cgi'
require 'oauth2'

#Yelp.configure(:yws_id          => 'YOUR_YWSID',
#               :consumer_key    => 'juPRropBZYGyz-r2yYvMOg',
#               :consumer_secret => 'zMlQCHGtF9HZpgpmDaPaU-Q7x0A',
#               :token           => '-faytblhHy1tqInc9oQ7FhMoH_6t5Fph',
#               :token_secret    => 'TcPeZLVXdcRk2PC67Q3psfCbCwY')
               
Yelp.client.configure do |config|
  config.consumer_key = "juPRropBZYGyz-r2yYvMOg"
  config.consumer_secret = "zMlQCHGtF9HZpgpmDaPaU-Q7x0A"
  config.token = "-faytblhHy1tqInc9oQ7FhMoH_6t5Fph"
  config.token_secret = "TcPeZLVXdcRk2PC67Q3psfCbCwY"
end

client = Uber::Client.new do |config|
  config.server_token  = "oylZjSywhatFk8VNG-7JndnniuD97aqBpErSBe_L"
  config.client_id     = "45K8ixUAozXT-O5zGp2AOTVgHb7ZZkgD"
  config.client_secret = "1nJ7v4OTF_mCX2Wl3AcajtDUNdjClfIR9c-CRD0J"

end


get '/' do
  @title =   "Uber to Yelp app"

  erb :index
end
post '/new' do

  
  what = params[:content]
  puts what
  loc = params[:content2]
  puts "The loc is #{loc}" 
  wherefrom = params[:content3]
  # encode address to pass into URL
  escapedwherefrom = CGI.escape(wherefrom)

  # First, geocode our location with Google API
  url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{escapedwherefrom}&sensor=false&key=AIzaSyBuvgW5-Sg7zhL1yrEGYKahpM6lsZmb0sk"
  
  widget = HTTParty.get(url)
  puts "google:"
  puts widget

 # this is our coordinates from where we re coming from
 lat = widget['results'].first['geometry']['location']['lat'].to_s
 long = widget['results'].first['geometry']['location']['lng'].to_s
puts "lat #{lat}"
 puts "long #{long}"
  # construct a client instance for the restaurant we want to go to
 response = Yelp.client.search("#{loc}", { term: "#{what}", limit: '1' })

 puts JSON.pretty_generate(response)
 name =  response.businesses[0].name
 address =  response.businesses[0].location.address
 zip = response.businesses[0].location.postal_code
 puts zip
 latrestaurant = response.businesses[0].location.coordinate.latitude
 longrestaurant = response.businesses[0].location.coordinate.longitude
 puts lat
 puts long
 # puts client.products(latitude: response.businesses[0].location.coordinate.latitude, longitude: response.businesses[0].location.coordinate.longitude)

 # Get Uber products
 url = "https://sandbox-api.uber.com/v1/products?latitude=#{lat}&longitude=#{long}"
 puts url
 widgetUber = HTTParty.get(url, 
     :headers => { 'Authorization' => "Token oylZjSywhatFk8VNG-7JndnniuD97aqBpErSBe_L" } )
    
 puts widgetUber
 puts "products"
 puts widgetUber['products']
 puts " cost " 
 puts widgetUber['products'].first['price_details']['cost_per_minute'].to_s
 
 
 erb :resp, :locals => {:widgetUber => widgetUber, :response => response, :content3 => wherefrom}

#  client.products(latitude: lat, longitude: lon)
#client.price_estimations(start_latitude: slat, start_longitude: slon,
#                         end_latitude: dlat, end_longitude: dlon)
end
