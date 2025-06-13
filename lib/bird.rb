require_relative 'environment'

class Bird
  attr_reader :y, :x, :vertical_speed

  def initialize
    @y = Environment::STARTING_Y  # Starting height (middle of screen)
    @x = Environment::STARTING_X  # Starting horizontal position
    @vertical_speed = 0   # Initial vertical speed
    @wing_state = :up
    @wing_timer = 0
  end

  def update
    # Vertical movement
    @vertical_speed += Environment::GRAVITY
    @y += @vertical_speed

    # Keep bird within screen bounds
    @y = Environment::CEILING_LEVEL if @y < Environment::CEILING_LEVEL
    @y = Environment::GROUND_LEVEL if @y > Environment::GROUND_LEVEL

    # Update wing animation
    if @wing_timer > 0
      @wing_timer -= 1
    elsif @wing_state == :down
      @wing_state = :up
    end
  end

  def jump
    @vertical_speed = Environment::JUMP_FORCE
    @wing_state = :down
    @wing_timer = 3  # Keep wings down for 3 frames after jump
  end

  def to_s
    case @wing_state
    when :up
      '=^o>'
    when :down
      '=vo>'
    end
  end

  # Returns the x-coordinates of the 3 rightmost characters (hitbox)
  # The tail is immune to collisions
  def hitbox_x
    [@x + 1, @x + 2, @x + 3]
  end
end
