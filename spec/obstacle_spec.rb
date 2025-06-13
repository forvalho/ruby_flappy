require_relative '../lib/obstacle'
require_relative '../lib/environment'
require_relative '../lib/bird'

RSpec.describe Obstacle do
  describe '#initialize' do
    it 'sets the initial position and dimensions' do
      obstacle = Obstacle.new(10, 5, 3, 10)
      expect(obstacle.x).to eq(10)
      expect(obstacle.top_height).to eq(5)
      expect(obstacle.bottom_height).to eq(3)
      expect(obstacle.spacing).to eq(10)
    end
  end

  describe '#update' do
    it 'moves the obstacle left' do
      obstacle = Obstacle.new(10, 5, 3, 10)
      initial_x = obstacle.x
      obstacle.update
      expect(obstacle.x).to eq(initial_x - Environment::HORIZONTAL_SPEED)
    end
  end

  describe '#right_edge' do
    it 'returns the right edge position' do
      obstacle = Obstacle.new(10, 5, 3, 10)
      expect(obstacle.right_edge).to eq(10 + Environment::OBSTACLE_WIDTH - 1)
    end
  end

  describe '#to_s' do
    it 'returns the obstacle character repeated for width' do
      obstacle = Obstacle.new(10, 5, 3, 10)
      expect(obstacle.to_s).to eq('#' * Environment::OBSTACLE_WIDTH)
    end
  end

  describe '.create_pair' do
    it 'creates a pair of obstacles with appropriate heights' do
      obstacle = Obstacle.create_pair(10)
      expect(obstacle.x).to eq(10)
      expect(obstacle.top_height + obstacle.bottom_height + Environment::OBSTACLE_GAP).to eq(Environment::GROUND_LEVEL - Environment::CEILING_LEVEL)
      expect(obstacle.spacing).to be_between(Environment::OBSTACLE_MIN_SPACING, Environment::OBSTACLE_MAX_SPACING)
    end
  end

  describe '#collides_with?' do
    let(:obstacle) { Obstacle.new(10, 5, 3, 10) }
    let(:bird) { Bird.new }

    it 'detects collision with top obstacle' do
      bird.instance_variable_set(:@x, 11)  # Align with obstacle
      bird.instance_variable_set(:@y, 4)   # Position in top obstacle
      expect(obstacle.collides_with?(bird)).to be true
    end

    it 'detects collision with bottom obstacle' do
      bird.instance_variable_set(:@x, 11)  # Align with obstacle
      bird.instance_variable_set(:@y, Environment::GROUND_LEVEL - 2)  # Position in bottom obstacle
      expect(obstacle.collides_with?(bird)).to be true
    end

    it 'allows bird to pass through gap' do
      bird.instance_variable_set(:@x, 11)  # Align with obstacle
      bird.instance_variable_set(:@y, 6)   # Position in gap
      expect(obstacle.collides_with?(bird)).to be false
    end

    it 'allows bird tail to pass through' do
      bird.instance_variable_set(:@x, obstacle.x - 4)  # Tail at obstacle.x - 4, hitbox at [obstacle.x - 3, obstacle.x - 2, obstacle.x - 1]
      bird.instance_variable_set(:@y, 4)   # Position in top obstacle
      expect(obstacle.collides_with?(bird)).to be false
    end

    it 'detects collision with any part of hitbox' do
      bird.instance_variable_set(:@x, 9)   # Position hitbox over obstacle
      bird.instance_variable_set(:@y, 4)   # Position in top obstacle
      expect(obstacle.collides_with?(bird)).to be true
    end
  end
end
