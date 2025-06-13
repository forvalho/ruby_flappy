require_relative '../lib/obstacle'

RSpec.describe Obstacle do
  let(:x) { 10 }
  let(:y) { 5 }
  let(:obstacle) { Obstacle.new(x, y) }

  describe '#initialize' do
    it 'sets the initial position' do
      expect(obstacle.x).to eq(x)
      expect(obstacle.y).to eq(y)
    end
  end

  describe '#update' do
    it 'moves the obstacle left' do
      initial_x = obstacle.x
      obstacle.update
      expect(obstacle.x).to eq(initial_x - Environment::HORIZONTAL_SPEED)
    end

    it 'does not change y position' do
      initial_y = obstacle.y
      obstacle.update
      expect(obstacle.y).to eq(initial_y)
    end
  end

  describe '#to_s' do
    it 'returns the obstacle character' do
      expect(obstacle.to_s).to eq('#')
    end
  end
end
