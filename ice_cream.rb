# GET /search?q=fun HTTP/1.1
# Host: bing.com


# GET /wiki/Main_Page http/1.1
# Host: en.wikipedia.org


# GET /

# http://maps.googleapis.com/maps/api/geocode/output?parameters

# output = JSON
# parameters 
#   address ***
#   sensor = false
#   



require 'rest-client'
require 'addressable/uri'

# parse address into a request, with correct parameters, return that request
def get_lat_long(address)

  lat_long = Addressable::URI.new(
    :scheme => "http",
    :host => "maps.googleapis.com",
    :path => "maps/api/geocode/json",
    :query_values =>
                    {:address => address,
                      :sensor => "false"}
    ).to_s
  lat_long

  

end

# SCRIPT
a = "160 Folsom St, San Francisco, CA"
puts get_lat_long(a)