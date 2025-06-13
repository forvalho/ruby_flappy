require_relative '../lib/obstacle'
require_relative '../lib/environment'

RSpec.describe Obstacle do
  describe '#initialize' do
    it 'sets the initial position and dimensions' do
      obstacle = Obstacle.new(10, 5, 3)
      expect(obstacle.x).to eq(10)
      expect(obstacle.top_height).to eq(5)
      expect(obstacle.bottom_height).to eq(3)
    end
  end

  describe '#update' do
    it 'moves the obstacle left' do
      obstacle = Obstacle.new(10, 5, 3)
      initial_x = obstacle.x
      obstacle.update
      expect(obstacle.x).to eq(initial_x - Environment::HORIZONTAL_SPEED)
    end
  end

  describe '#right_edge' do
    it 'returns the right edge position' do
      obstacle = Obstacle.new(10, 5, 3)
      expect(obstacle.right_edge).to eq(10 + Environment::OBSTACLE_WIDTH - 1)
    end
  end

  describe '#to_s' do
    it 'returns the obstacle character repeated for width' do
      obstacle = Obstacle.new(10, 5, 3)
      expect(obstacle.to_s).to eq('#' * Environment::OBSTACLE_WIDTH)
    end
  end

  describe '.create_pair' do
    it 'creates a pair of obstacles with appropriate heights' do
      obstacle = Obstacle.create_pair(10)
      expect(obstacle.x).to eq(10)
      expect(obstacle.top_height + obstacle.bottom_height + Environment::OBSTACLE_GAP).to eq(Environment::GROUND_LEVEL - Environment::CEILING_LEVEL)
    end
  end
end
