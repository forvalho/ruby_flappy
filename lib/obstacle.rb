require_relative 'environment'

class Obstacle
  attr_reader :x, :top_height, :bottom_height, :spacing
  attr_writer :x

  def initialize(x, top_height, bottom_height, spacing)
    @x = x
    @top_height = top_height
    @bottom_height = bottom_height
    @spacing = spacing
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
    spacing = rand(Environment::OBSTACLE_MIN_SPACING..Environment::OBSTACLE_MAX_SPACING)

    Obstacle.new(x, top_height, bottom_height, spacing)
  end

  # Returns true if the bird collides with this obstacle
  def collides_with?(bird)
    bird.hitbox_x.each do |bx|
      # Check horizontal overlap
      next unless bx >= @x && bx <= right_edge
      # Check vertical overlap (top obstacle)
      return true if bird.y < @top_height
      # Check vertical overlap (bottom obstacle)
      return true if bird.y > (Environment::GROUND_LEVEL - @bottom_height - 1)
    end
    false
  end
end
