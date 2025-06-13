class Bird
  attr_reader :position, :velocity

  def initialize
    @position = 10  # Starting height
    @velocity = 0   # Initial velocity
    @gravity = 0.5  # Gravity constant
    @jump_force = -5 # Jump force (negative because y increases downward)
  end

  def update
    @velocity += @gravity
    @position += @velocity
  end

  def jump
    @velocity = @jump_force
  end

  def to_s
    '🐦'
  end
end
