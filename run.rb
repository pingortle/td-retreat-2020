require "curses"
require "game-client"

# Setup authorization
GameClient.configure do |config|
  # Configure Bearer authorization: token
  config.host = "http://td-capture-the-flag.herokuapp.com" # https://example.com
  config.access_token = ENV.fetch("CTF_ACCESS_TOKEN", "kaleb@testdouble.com") # # alice@example.com
end

class MovesPlayer
  include Curses

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

    player = result.player
    char = player.has_peg ? "X" : "x"
    char = "!" unless player.is_in_safe_zone
    char = "$" if player.has_flag
    Curses.setpos(player.y + 10, player.x)
    Curses.addch(char)

    result.opponents.each do |opponent|
      Curses.setpos(opponent.y + 10, opponent.x)
      char = opponent.has_peg ? "O" : "o"
      char = "F" if opponent.has_flag
      Curses.addch(char)
    end
  end
end

mover = MovesPlayer.new(GameClient::GameApi.new)

Curses.noecho # do not show typed keys
Curses.init_screen
# Curses.start_color
# Curses.init_pair(Curses::COLOR_BLUE, Curses::COLOR_BLUE, Curses::COLOR_WHITE)
# Curses.init_pair(Curses::COLOR_RED, Curses::COLOR_RED, Curses::COLOR_WHITE)
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
