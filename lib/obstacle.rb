require_relative 'environment'

class Obstacle
  attr_reader :x, :top_height, :bottom_height
  attr_writer :x

  def initialize(x, top_height, bottom_height)
    @x = x
    @top_height = top_height
    @bottom_height = bottom_height
  end

  def update
    @x -= Environment::HORIZONTAL_SPEED
  end

  def right_edge
    @x + Environment::OBSTACLE_WIDTH - 1
  end

  def to_s
    '#' * Environment::OBSTACLE_WIDTH
  end

  def self.create_pair(x)
    total_height = Environment::GROUND_LEVEL - Environment::CEILING_LEVEL
    available_height = total_height - Environment::OBSTACLE_GAP
    min_height = Environment::OBSTACLE_MIN_HEIGHT
    max_height = available_height - min_height

    top_height = rand(min_height..max_height)
    bottom_height = available_height - top_height

    Obstacle.new(x, top_height, bottom_height)
  end
end
