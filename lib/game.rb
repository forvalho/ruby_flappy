require_relative 'bird'
require_relative 'environment'
require_relative 'obstacle'
require 'curses'

class Game
  attr_reader :obstacles, :last_obstacle_x

  def initialize
    @bird = Bird.new
    @obstacles = []
    @running = true
    @last_obstacle_x = Environment::SCREEN_WIDTH
  end

  def run
    # Initialize the Curses screen
    Curses.init_screen      # Start curses mode
    Curses.crmode          # Set terminal to raw mode (no line buffering)
    Curses.noecho          # Don't echo input characters
    Curses.stdscr.keypad(true)  # Enable keypad mode for special keys
    Curses.curs_set(0)     # Hide the cursor (0 = invisible, 1 = normal, 2 = very visible)

    # Initialize colors
    Curses.start_color
    # Define color pairs:
    # 1: White on light blue (sky)
    # 2: Black on green (ground)
    # 3: White on brown (below ground)
    Curses.init_pair(1, Curses::COLOR_WHITE, Curses::COLOR_CYAN)    # Sky
    Curses.init_pair(2, Curses::COLOR_BLACK, Curses::COLOR_GREEN)   # Ground
    Curses.init_pair(3, Curses::COLOR_WHITE, Curses::COLOR_YELLOW)  # Below ground (using yellow as brown)

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
    update_obstacles
    maybe_add_obstacle
  end

  def update_obstacles
    @obstacles.each(&:update)
    @obstacles.reject! { |obs| obs.x < 0 }  # Remove obstacles that are off screen
  end

  def maybe_add_obstacle
    rightmost_x = @obstacles.map(&:x).max || -Float::INFINITY
    if @obstacles.empty? || (Environment::SCREEN_WIDTH - rightmost_x >= rand(3..10))
      @obstacles << Obstacle.new(Environment::SCREEN_WIDTH, Environment::CEILING_LEVEL)
      @obstacles << Obstacle.new(Environment::SCREEN_WIDTH, Environment::GROUND_LEVEL)
    end
  end

  def draw
    @window.clear

    # Draw sky (light blue background)
    @window.attron(Curses.color_pair(1))
    @window.setpos(0, 0)
    @window.addstr(' ' * (Environment::SCREEN_WIDTH * Environment::GROUND_LEVEL))

    # Draw ground (green)
    @window.attron(Curses.color_pair(2))
    @window.setpos(Environment::GROUND_LEVEL, 0)
    @window.addstr(' ' * Environment::SCREEN_WIDTH)

    # Draw below ground (brown)
    @window.attron(Curses.color_pair(3))
    @window.setpos(Environment::GROUND_LEVEL + 1, 0)
    @window.addstr(' ' * (Environment::SCREEN_WIDTH * (Environment::SCREEN_HEIGHT - Environment::GROUND_LEVEL - 1)))

    # Draw obstacles
    @window.attron(Curses.color_pair(2))  # Use green for obstacles
    @obstacles.each do |obstacle|
      @window.setpos(obstacle.y, obstacle.x)
      @window.addstr(obstacle.to_s)
    end

    # Draw bird (on top of everything)
    @window.attron(Curses.color_pair(1))  # Reset to sky color for bird
    @window.setpos(@bird.y, @bird.x)
    @window.addstr(@bird.to_s)

    @window.refresh
  end
end

# Run the game if this file is executed directly
if __FILE__ == $PROGRAM_NAME
  Game.new.run
end
