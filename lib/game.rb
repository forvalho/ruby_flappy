require_relative 'bird'
require_relative 'environment'
require 'curses'

class Game
  def initialize
    @bird = Bird.new
    @running = true
  end

  def run
    # Initialize the Curses screen
    Curses.init_screen      # Start curses mode
    Curses.crmode          # Set terminal to raw mode (no line buffering)
    Curses.noecho          # Don't echo input characters
    Curses.stdscr.keypad(true)  # Enable keypad mode for special keys
    Curses.curs_set(0)     # Hide the cursor (0 = invisible, 1 = normal, 2 = very visible)

    # Set up the game window
    @window = Curses::Window.new(
      Environment::SCREEN_HEIGHT,
      Environment::SCREEN_WIDTH,
      0, 0
    )
    @window.keypad(true)   # Enable keypad mode for the window
    @window.timeout = 0    # Make getch non-blocking

    game_loop
  ensure
    Curses.close_screen    # Clean up curses before exiting
  end

  private

  def game_loop
    while @running
      handle_input
      update
      draw
      sleep(Environment::FRAME_RATE)  # Control game speed using environment constant
    end
  end

  def handle_input
    case @window.getch
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
    @window.clear
    @window.setpos(@bird.position, 10)
    @window.addstr(@bird.to_s)

    # Draw ground
    @window.setpos(Environment::GROUND_LEVEL + 1, 0)
    @window.addstr('=' * Environment::SCREEN_WIDTH)

    @window.refresh
  end
end

# Run the game if this file is executed directly
if __FILE__ == $PROGRAM_NAME
  Game.new.run
end
