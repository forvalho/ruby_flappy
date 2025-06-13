require_relative 'environment'

class Bird
  attr_reader :position, :velocity

  def initialize
    @position = 10  # Starting height
    @velocity = 0   # Initial velocity
    @wing_state = :up
    @wing_timer = 0
  end

  def update
    @velocity += Environment::GRAVITY
    @position += @velocity

    # Keep bird within screen bounds
    @position = Environment::CEILING_LEVEL if @position < Environment::CEILING_LEVEL
    @position = Environment::GROUND_LEVEL if @position > Environment::GROUND_LEVEL

    # Update wing animation
    if @wing_timer > 0
      @wing_timer -= 1
    elsif @wing_state == :down
      @wing_state = :up
    end
  end

  def jump
    @velocity = Environment::JUMP_FORCE
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
end
