# Sarah and Erik's Twitter client

require 'oauth'
require 'launchy'
require 'yaml'

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
    #while true
      puts "\nHI! Welcome to the TWITTERSPAMBOT26103678!"
      # ask for user input!  get 4 possible commands, run those methods.
      case user_input
        when "p" then post_status
        when "t" then get_timeline
        when "s" then get_statuses
        when "d" then send_direct_message
        when "q" then exit
      end
    #end
  end

  def user_input
    input_command = ''
    puts "Command format: "
    puts "['p' = post tweet, 't' = get timeline,'s' = get user status, 'd' = send direct message, 'q' = quit]"
    until VALID_COMMANDS.include?(input_command)
      print "Enter a valid command: "
      input_command = gets.chomp
    end
    input_command
  end

  def post_status

  end

  def get_timeline
    @access_token.get("http://api.twitter.com/1.1/statuses/user_timeline.json").body
  end

  def get_statuses

  end

  def send_direct_message

    # ask for the recipient

    # send the message

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
