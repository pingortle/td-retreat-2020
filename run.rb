require "curses"
require "game-client"

# Setup authorization
GameClient.configure do |config|
  # Configure Bearer authorization: token
  config.host = "http://td-capture-the-flag.herokuapp.com" # https://example.com
  config.access_token = ENV.fetch("CTF_ACCESS_TOKEN", "kaleb@testdouble.com") # # alice@example.com
end

class MovesPlayer
  def initialize(api)
    @api = api
  end

  def move!(direction)
    Curses.clear
    Curses.setpos(0, 0)
    Curses.addstr("Moving…")

    result = @api.post_moves(direction)

    Curses.clear
    Curses.setpos(0, 0)
    Curses.addstr("Moved #{result}")
  end
end

mover = MovesPlayer.new(GameClient::GameApi.new)

Curses.noecho # do not show typed keys
Curses.init_screen
Curses.stdscr.keypad(true) # enable arrow keys (required for pageup/down)

loop do
  case Curses.getch
  when Curses::Key::LEFT
    mover.move!("west")
  when Curses::Key::RIGHT
    mover.move!("east")
  when Curses::Key::UP
    mover.move!("north")
  when Curses::Key::DOWN
    mover.move!("south")
  end

rescue GameClient::ApiError => e
  Curses.setpos(0, 0)
  Curses.addstr("Exception when calling GameApi->get_player: #{e}")
end
