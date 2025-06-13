require_relative '../lib/game'
require_relative '../lib/environment'

RSpec.describe Game do
  let(:game) { Game.new }

  describe '#initialize' do
    it 'creates a new game with a bird and empty obstacles' do
      expect(game.obstacles).to be_empty
    end
  end

  describe '#maybe_add_obstacle' do
    it 'adds an obstacle pair when there are no obstacles' do
      game.send(:maybe_add_obstacle)
      expect(game.obstacles.length).to eq(1)
      expect(game.obstacles.first).to be_a(Obstacle)
    end

    it 'adds an obstacle pair when the last obstacle is far enough' do
      # Add an initial obstacle
      game.send(:maybe_add_obstacle)
      initial_obstacle = game.obstacles.first

      # Move the obstacle far enough to the left
      initial_obstacle.x = Environment::SCREEN_WIDTH - Environment::OBSTACLE_SPACING - Environment::OBSTACLE_WIDTH - 1

      # Try to add another obstacle
      game.send(:maybe_add_obstacle)
      expect(game.obstacles.length).to eq(2)
    end

    it 'does not add an obstacle when the last obstacle is too close' do
      # Add an initial obstacle
      game.send(:maybe_add_obstacle)
      initial_obstacle = game.obstacles.first

      # Move the obstacle too close to the right edge
      initial_obstacle.x = Environment::SCREEN_WIDTH - Environment::OBSTACLE_SPACING + 1

      # Try to add another obstacle
      game.send(:maybe_add_obstacle)
      expect(game.obstacles.length).to eq(1)
    end
  end

  describe '#update_obstacles' do
    it 'removes obstacles that are off screen' do
      # Add an obstacle
      game.send(:maybe_add_obstacle)
      obstacle = game.obstacles.first

      # Move it off screen
      obstacle.x = -Environment::OBSTACLE_WIDTH - 1

      # Update obstacles
      game.send(:update_obstacles)
      expect(game.obstacles).to be_empty
    end
  end
end
