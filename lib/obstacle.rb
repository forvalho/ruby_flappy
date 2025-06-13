class Obstacle
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def update
    @x -= Environment::HORIZONTAL_SPEED
  end

  def to_s
    '#'
  end
end
