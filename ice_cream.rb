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
require 'json'

# parse address into a request, with correct parameters, return that request
def get_lat_long(address="160 Folsom st, san francisco, ca")

  url = Addressable::URI.new(
    :scheme => "http",
    :host => "maps.googleapis.com",
    :path => "maps/api/geocode/json",
    :query_values =>
                    {:address => address,
                      :sensor => "false"}
    ).to_s

  response = RestClient.get(url)
  json_response = JSON.parse(response)
  lat = json_response["results"][0]["geometry"]["location"]["lat"]
  lng = json_response["results"][0]["geometry"]["location"]["lng"]
  return "#{lat},#{lng}"
end

def get_best_nearby_place(search_term)
  api_key = "AIzaSyC46s2QgmoT4-GBpTC6xucm2HcHiwRnS_o"
  lat_long = get_lat_long

  url = Addressable::URI.new(
  :scheme => "https",
  :host => "maps.googleapis.com",
  :path => "maps/api/place/nearbysearch/json",
  :query_values =>
                  {:key => api_key,
                    :location => lat_long,
                    :radius => 500,
                    :sensor => "false",
                    :keyword => search_term}
  ).to_s
  response = RestClient.get(url)
  json_response = JSON.parse(response)
  nearby_places = trim_places_results(json_response)
  # sort the results, return highest rated
  best_place = get_highest_rated_place(nearby_places)
  p " BEST PLACE IS: #{best_place}"
  p "The best place we found was: #{best_place[:name]}!"
end

# Will trim the json object to keep only the parameters we like, easily accessible
def trim_places_results(places_json_object)
  trimmed_places = []

  places_json_object["results"].each do |place|
    current_place = {}
    current_place[:name] = place["name"]
    current_place[:rating] = place["rating"]
    current_place[:lat] = place["geometry"]["location"]["lat"]
    current_place[:lng] = place["geometry"]["location"]["lng"]
    trimmed_places << current_place
  end
  trimmed_places
end

# takes the trimmed array of nearby places, and returns the highest rated one
def get_highest_rated_place(nearby_places)

  nearby_places.sort.last

end

def get_directions(from_lat_lng, to_lat_lng)

end

def <=>(result_hash)
  self[:rating] <=> result_hash[:rating]
end


# SCRIPT

get_best_nearby_place("Ice Cream")
