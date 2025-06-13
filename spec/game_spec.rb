require_relative '../lib/game'
require_relative '../lib/environment'

RSpec.describe Game do
  let(:game) { Game.new }

  describe '#initialize' do
    it 'creates a new game with a bird, empty obstacles, and 3 lives' do
      expect(game.obstacles).to be_empty
      expect(game.instance_variable_get(:@lives)).to eq(3)
    end
  end

  describe '#maybe_add_obstacle' do
    it 'adds an obstacle pair when there are no obstacles' do
      game.send(:maybe_add_obstacle)
      expect(game.obstacles.length).to eq(1)
      expect(game.obstacles.first).to be_a(Obstacle)
    end

    it 'adds an obstacle pair when the last obstacle is far enough' do
      allow(game).to receive(:rand).and_return(Environment::OBSTACLE_MIN_SPACING)
      game.send(:maybe_add_obstacle)
      initial_obstacle = game.obstacles.first

      # Move the obstacle far enough to the left
      initial_obstacle.x = Environment::SCREEN_WIDTH - Environment::OBSTACLE_MIN_SPACING - Environment::OBSTACLE_WIDTH - 1

      # Try to add another obstacle
      game.send(:maybe_add_obstacle)
      expect(game.obstacles.length).to eq(2)
    end

    it 'does not add an obstacle when the last obstacle is too close' do
      # Add an initial obstacle
      game.send(:maybe_add_obstacle)
      initial_obstacle = game.obstacles.first

      # Move the obstacle too close to the right edge
      initial_obstacle.x = Environment::SCREEN_WIDTH - Environment::OBSTACLE_MIN_SPACING + 1

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

  describe '#handle_collision' do
    it 'decrements lives and resets game when lives remain' do
      initial_lives = game.instance_variable_get(:@lives)
      game.send(:handle_collision)
      expect(game.instance_variable_get(:@lives)).to eq(initial_lives - 1)
      expect(game.obstacles).to be_empty  # Game should be reset
    end

    it 'ends game when no lives remain' do
      # Set lives to 1
      game.instance_variable_set(:@lives, 1)
      game.send(:handle_collision)
      expect(game.instance_variable_get(:@running)).to be false
    end
  end

  describe 'collision detection' do
    it 'detects ceiling collision' do
      bird = game.instance_variable_get(:@bird)
      bird.instance_variable_set(:@y, Environment::CEILING_LEVEL - 1)
      game.send(:update)
      expect(game.instance_variable_get(:@lives)).to eq(2)
    end

    it 'detects floor collision' do
      bird = game.instance_variable_get(:@bird)
      bird.instance_variable_set(:@y, Environment::GROUND_LEVEL)
      game.send(:update)
      expect(game.instance_variable_get(:@lives)).to eq(2)
    end

    it 'detects obstacle collision' do
      bird = game.instance_variable_get(:@bird)
      obstacle = Obstacle.create_pair(Environment::SCREEN_WIDTH / 2)
      game.obstacles << obstacle

      # Position bird to collide with obstacle
      bird.instance_variable_set(:@x, obstacle.x + 1)  # Align with obstacle
      bird.instance_variable_set(:@y, Environment::CEILING_LEVEL + 1)  # Position in collision zone

      game.send(:update)
      expect(game.instance_variable_get(:@lives)).to eq(2)
    end
  end
end
