require_relative 'environment'

class Bird
  attr_reader :position, :velocity

  def initialize
    @position = 10  # Starting height
    @velocity = 0   # Initial velocity
  end

  def update
    @velocity += Environment::GRAVITY
    @position += @velocity

    # Keep bird within screen bounds
    @position = Environment::CEILING_LEVEL if @position < Environment::CEILING_LEVEL
    @position = Environment::GROUND_LEVEL if @position > Environment::GROUND_LEVEL
  end

  def jump
    @velocity = Environment::JUMP_FORCE
  end

  def to_s
    '🐦'
  end
end
