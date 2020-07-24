require 'curses'
require "game-client"

# Setup authorization
GameClient.configure do |config|
  # Configure Bearer authorization: token
  config.host = "http://td-capture-the-flag.herokuapp.com" # https://example.com
  config.access_token = "kaleb@testdouble.com" # alice@example.com
end

api_instance = GameClient::GameApi.new

Curses.noecho # do not show typed keys
Curses.init_screen
Curses.stdscr.keypad(true) # enable arrow keys (required for pageup/down)

loop do
  case Curses.getch
  when Curses::Key::LEFT
    api_instance.post_moves("west")
  when Curses::Key::RIGHT
    api_instance.post_moves("east")
  when Curses::Key::UP
    api_instance.post_moves("north")
  when Curses::Key::DOWN
    api_instance.post_moves("south")
  end

rescue GameClient::ApiError => e
  puts "Exception when calling GameApi->get_player: #{e}"
end

# begin
#   # Get Player
#   result = api_instance.get_player
#   pp result
# rescue GameClient::ApiError => e
#   puts "Exception when calling GameApi->get_player: #{e}"
# end
