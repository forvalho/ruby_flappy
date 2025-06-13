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
    @lives = 3  # Start with 3 lives
    @points = 0  # Start with 0 points
    @countdown = 3  # Start with 3 seconds countdown
  end

  def reset_game
    @bird = Bird.new
    @obstacles = []
    @last_obstacle_x = Environment::SCREEN_WIDTH
    @countdown = 3  # Reset countdown to 3 seconds
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
    # 4: White on black (lives display)
    Curses.init_pair(1, Curses::COLOR_WHITE, Curses::COLOR_CYAN)    # Sky
    Curses.init_pair(2, Curses::COLOR_BLACK, Curses::COLOR_GREEN)   # Ground
    Curses.init_pair(3, Curses::COLOR_WHITE, Curses::COLOR_YELLOW)  # Below ground (using yellow as brown)
    Curses.init_pair(4, Curses::COLOR_WHITE, Curses::COLOR_BLACK)   # Lives display

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
      if @countdown.nil?
        update
      else
        sleep(1)  # Wait for 1 second
        @countdown -= 1
        if @countdown < 0
          @countdown = nil  # End countdown
        end
      end
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
    return if @countdown  # Don't update game state during countdown

    @bird.update
    update_obstacles
    maybe_add_obstacle
    check_points

    # Collision detection
    if @bird.y <= Environment::CEILING_LEVEL || @bird.y >= Environment::GROUND_LEVEL
      handle_collision
    elsif @obstacles.any? { |obs| obs.collides_with?(@bird) }
      handle_collision
    end
  end

  def handle_collision
    @lives -= 1
    if @lives <= 0
      @running = false
    else
      reset_game
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

  def check_points
    @obstacles.each do |obstacle|
      # Check if bird's leftmost hitbox position has passed the obstacle
      if @bird.hitbox_x.first > obstacle.right_edge
        @points += 1
        # Remove the obstacle to avoid counting it again
        @obstacles.delete(obstacle)
      end
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

    # Draw points in bottom left corner
    @window.attron(Curses.color_pair(4))  # White on black
    @window.setpos(Environment::SCREEN_HEIGHT - 2, 1)  # 1 block from bottom and left edges
    @window.addstr(@points.to_s)

    # Draw lives in bottom right corner
    @window.attron(Curses.color_pair(4))  # White on black
    @window.setpos(Environment::SCREEN_HEIGHT - 2, Environment::SCREEN_WIDTH - 2)  # 1 block from bottom and right edges
    @window.addstr(@lives.to_s)

    # Draw countdown if active
    if @countdown
      # Draw black box for countdown
      countdown_y = Environment::SCREEN_HEIGHT / 2
      countdown_x = Environment::SCREEN_WIDTH / 2 - 1
      @window.attron(Curses.color_pair(4))  # White on black
      @window.setpos(countdown_y, countdown_x)
      @window.addstr(' ' * 3)  # Black box background
      @window.setpos(countdown_y, countdown_x + 1)
      @window.addstr(@countdown.to_s)
    end

    @window.refresh
  end
end

# Run the game if this file is executed directly
if __FILE__ == $PROGRAM_NAME
  Game.new.run
end
