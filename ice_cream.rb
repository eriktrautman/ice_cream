
require 'rest-client'
require 'addressable/uri'
require 'json'
require 'nokogiri'

class IceCreamFinder
  def run
    best_place = get_best_nearby_place("Ice cream")
    to_lat_lng = "#{best_place[:lat]},#{best_place[:lng]}"
    from_lat_lng = get_lat_long

    json_directions = get_directions(from_lat_lng, to_lat_lng)
    trimmed_directions = trim_direction_results(json_directions)
    print_directions(trimmed_directions)
  end

  # parse address into a request, with correct parameters, return that request
  def get_lat_long(address="160 Folsom st, san francisco, CA")

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
    p "The best place we found was: #{best_place[:name]}!"
    best_place
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
    nearby_places.sort { |res1, res2| res1[:rating] <=> res2[:rating] }.last
  end

  def get_directions(from_lat_lng, to_lat_lng)

    api_key = "AIzaSyC46s2QgmoT4-GBpTC6xucm2HcHiwRnS_o"

    url = Addressable::URI.new(
    :scheme => "https",
    :host => "maps.googleapis.com",
    :path => "maps/api/directions/json",
    :query_values =>
                    { :origin => from_lat_lng,
                      :destination => to_lat_lng,
                      :sensor => "false",
                      :mode => "walking"
                    }
    ).to_s

    response = RestClient.get(url)
    json_response = JSON.parse(response)

    json_response
  end

  def trim_direction_results(json_directions)
    directions_hash = {}

    directions_hash[:start_address] = json_directions["routes"][0]["legs"][0]["start_address"]
    directions_hash[:end_address] = json_directions["routes"][0]["legs"][0]["end_address"]
    directions_hash[:steps] = json_directions["routes"][0]["legs"][0]["steps"]

    directions_hash
  end

  def print_directions(trimmed_directions)
    puts "Starting address:"
    puts trimmed_directions[:start_address]
    puts

    puts "Step by step directions:"
    trimmed_directions[:steps].each do |step|
      parsed_html_step_instructions = Nokogiri::HTML("#{step['html_instructions']}")
      puts parsed_html_step_instructions.text
      #puts step["html_instructions"]
      puts "#{step['distance']['text']}, #{step['duration']['text']}".rjust(40, " ")
    end
    puts

    puts "Destination:"
    puts trimmed_directions[:end_address]
  end

end  # END OF CLASS


# SCRIPT

#get_best_nearby_place("Ice Cream")

finder = IceCreamFinder.new
finder.run
