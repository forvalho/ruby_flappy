require_relative 'bird'
require 'curses'

class Game
  def initialize
    @bird = Bird.new
    @running = true
  end

  def run
    Curses.init_screen
    Curses.crmode
    Curses.noecho
    Curses.stdscr.keypad(true)
    Curses.curs_set(0)  # Hide cursor

    game_loop
  ensure
    Curses.close_screen
  end

  private

  def game_loop
    while @running
      handle_input
      update
      draw
      sleep(0.1)  # Control game speed
    end
  end

  def handle_input
    case Curses.getch
    when 'q'
      @running = false
    when ' '
      @bird.jump
    end
  end

  def update
    @bird.update
  end

  def draw
    Curses.clear
    Curses.setpos(@bird.position, 10)
    Curses.addstr(@bird.to_s)
    Curses.refresh
  end
end

# Run the game if this file is executed directly
if __FILE__ == $PROGRAM_NAME
  Game.new.run
end
