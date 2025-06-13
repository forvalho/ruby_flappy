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

    # Add initial obstacles from middle to right edge
    x = Environment::SCREEN_WIDTH / 2
    while x < Environment::SCREEN_WIDTH
      obstacle = Obstacle.create_pair(x)
      @obstacles << obstacle
      x += obstacle.spacing + Environment::OBSTACLE_WIDTH
    end
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

    # Collision detection
    if @bird.y <= Environment::CEILING_LEVEL + 1 || @bird.y >= Environment::GROUND_LEVEL
      @running = false
    elsif @obstacles.any? { |obs| obs.collides_with?(@bird) }
      @running = false
    end
  end

  def update_obstacles
    @obstacles.each(&:update)
    @obstacles.reject! { |obs| obs.right_edge <= 0 }  # Remove obstacles that are fully off screen
  end

  def maybe_add_obstacle
    rightmost_x = @obstacles.map(&:right_edge).max || -Float::INFINITY
    if @obstacles.empty? || (Environment::SCREEN_WIDTH - rightmost_x >= rand(Environment::OBSTACLE_MIN_SPACING..Environment::OBSTACLE_MAX_SPACING))
      @obstacles << Obstacle.create_pair(Environment::SCREEN_WIDTH)
    end
  end

  def draw
    # Clear the entire screen first
    @window.clear
    @window.attron(Curses.color_pair(1))  # Sky color
    (0...Environment::SCREEN_HEIGHT).each do |row|
      @window.setpos(row, 0)
      @window.addstr(' ' * Environment::SCREEN_WIDTH)
    end

    # Draw ground (green)
    @window.attron(Curses.color_pair(2))
    @window.setpos(Environment::GROUND_VISUAL_LEVEL, 0)
    @window.addstr(' ' * Environment::SCREEN_WIDTH)

    # Draw below ground (brown)
    @window.attron(Curses.color_pair(3))
    ((Environment::GROUND_VISUAL_LEVEL + 1)...Environment::SCREEN_HEIGHT).each do |row|
      @window.setpos(row, 0)
      @window.addstr(' ' * Environment::SCREEN_WIDTH)
    end

    # Draw obstacles
    @window.attron(Curses.color_pair(2))  # Use green for obstacles
    @obstacles.each do |obstacle|
      # Only draw if the obstacle is within screen bounds
      next if obstacle.x >= Environment::SCREEN_WIDTH || obstacle.right_edge <= 0

      # Calculate visible width (in case obstacle is partially off screen)
      visible_width = [Environment::OBSTACLE_WIDTH, Environment::SCREEN_WIDTH - obstacle.x].min
      next if visible_width <= 0

      # Draw top obstacle (from row 0 down for top_height rows)
      obstacle.top_height.times do |i|
        @window.setpos(i, obstacle.x)
        @window.addstr('#' * visible_width)
      end

      # Draw bottom obstacle (from just above ground line, extending upward)
      obstacle.bottom_height.times do |i|
        row = Environment::GROUND_VISUAL_LEVEL - i - 1
        @window.setpos(row, obstacle.x)
        @window.addstr('#' * visible_width)
      end
    end

    # Draw bird (on top of everything)
    @window.attron(Curses.color_pair(1))  # Sky color for bird
    @window.setpos(@bird.y, @bird.x)
    @window.addstr(@bird.to_s)

    @window.refresh
  end
end

# Run the game if this file is executed directly
if __FILE__ == $PROGRAM_NAME
  Game.new.run
end
