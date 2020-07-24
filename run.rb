require "curses"
require "game-client"

class DrawsResult
  def draw(result)
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

class MovesPlayer
  include Curses

  attr_reader :api

  def initialize(api)
    @api = api
  end

  def move!(direction)
    DrawsResult.new.draw(@api.post_moves(direction))
  end
end

GameClient.configure do |config|
  config.host = "http://td-capture-the-flag.herokuapp.com"
  config.access_token = ENV.fetch("CTF_ACCESS_TOKEN", "kaleb@testdouble.com")
end

Curses.noecho # do not show typed keys
Curses.init_screen
Curses.stdscr.keypad(true) # enable arrow keys (required for pageup/down)

api = GameClient::GameApi.new
mover = MovesPlayer.new(api)

DrawsResult.new.draw(api.get_player)

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
