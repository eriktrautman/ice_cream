# Sarah and Erik's Twitter client

require 'oauth'
require 'launchy'
require 'yaml'
require 'rest-client'
require 'addressable/uri'
require 'json'

# Username: SpamBot26103678
# Password: spambot

class TwitterBot

  VALID_COMMANDS = ["p", "t", "s", "d", "q"]
  CONSUMER_KEY = "FHsItt0JyVC5XvXroj5Qiw"
  CONSUMER_SECRET = "OsljlUmE3eY3lI0FAbney2VowltSpV1HFmF5Vs4"
  CONSUMER = OAuth::Consumer.new(
    CONSUMER_KEY, CONSUMER_SECRET, :site=> "http://twitter.com")

  def initialize
    @access_token = get_token("token.yml")
  end

  def run
    while true
      puts "\nHI! Welcome to the TWITTERSPAMBOT26103678!"
      # ask for user input!  get 4 possible commands, run those methods.
      case user_input
        when "p" then post_status
        when "t" then get_timeline
        when "s" then get_statuses
        when "d" then send_direct_message
        when "q" then exit
      end
    end
  end

  def user_input
    input_command = ''
    puts "\nCommand format: "
    puts "['p' = post tweet, 't' = get timeline,'s' = get user status, 'd' = send direct message, 'q' = quit]\n\n"
    until VALID_COMMANDS.include?(input_command)
      print "Enter a valid command: "
      input_command = gets.chomp
    end
    input_command
  end

  def post_status(dm_recipient=nil)
    tweet_body = get_tweet_body(dm_recipient)

    # if dm_recipient != nil
    #   tweet_body

    url = Addressable::URI.new(
      :scheme => "https",
      :host => "api.twitter.com",
      :path => "1.1/statuses/update.json",
      ).to_s
    p "URL IS : #{url}"
    params = {
      :status => tweet_body
    }

    response = @access_token.post(url, params)
    puts "TWEETED!!!"
  end

  def get_tweet_body(dm_recipient = nil)
    dm_recipient.nil? ? tweet_body = "" : tweet_body = "D #{dm_recipient} "
    p "Enter tweet text: #{tweet_body}"
    tweet_body += gets.chomp
    p tweet_body
    tweet_body
  end

  def get_timeline
    response = @access_token.get("http://api.twitter.com/1.1/statuses/user_timeline.json").body
    json_response = JSON.parse(response)
    json_response.each do |timeline_item|
      puts "TEXT: #{timeline_item["text"]}"
    end
  end

  def get_statuses
    # What the heck is this? Meh.  Ignored.
    get_timeline
  end

  def send_direct_message
    post_status(request_message_recipient)
  end

  def request_message_recipient
    recipient = nil
    while recipient.nil?
      puts "Who is your recipient?"
      recipient = gets.chomp
    end
    recipient
  end

  # ask the user to specify the recipient of the next function
  def ask_for_recipient

  end

  def request_access_token
    request_token = CONSUMER.get_request_token
    authorize_url = request_token.authorize_url
    Launchy.open(authorize_url)

    puts "Login, and type your verification code in"
    oauth_verifier = gets.chomp

    access_token = request_token.get_access_token(
        :oauth_verifier => oauth_verifier)
  end

  def get_token(token_file)
    if File.exist?(token_file)
      File.open(token_file) { |f| YAML.load(f) }
    else
      access_token = request_access_token
      File.open(token_file, "w") { |f| YAML.dump(access_token, f) }

      access_token
    end
  end
end

# SCRIPT
t = TwitterBot.new
t.run
