require_relative '../lib/game'
require_relative '../lib/environment'

RSpec.describe Game do
  let(:game) { Game.new }

  describe '#initialize' do
    it 'creates a new game with a bird, empty obstacles, and 3 lives' do
      expect(game.obstacles).to be_empty
      expect(game.instance_variable_get(:@lives)).to eq(3)
      expect(game.instance_variable_get(:@welcome_screen)).to be true
      expect(game.instance_variable_get(:@game_over)).to be false
    end
  end

  describe '#reset_game' do
    it 'resets all game state including welcome screen' do
      game.instance_variable_set(:@welcome_screen, false)
      game.instance_variable_set(:@game_over, true)
      game.instance_variable_set(:@points, 10)
      game.instance_variable_set(:@lives, 1)
      game.reset_game
      expect(game.instance_variable_get(:@welcome_screen)).to be false
      expect(game.instance_variable_get(:@game_over)).to be false
      expect(game.instance_variable_get(:@points)).to eq(0)
      expect(game.instance_variable_get(:@lives)).to eq(3)
    end
  end

  describe '#reset_after_death' do
    it 'resets game elements but preserves points and lives' do
      game.instance_variable_set(:@points, 10)
      game.instance_variable_set(:@lives, 2)
      game.reset_after_death
      expect(game.obstacles).to be_empty
      expect(game.instance_variable_get(:@points)).to eq(10)
      expect(game.instance_variable_get(:@lives)).to eq(2)
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
      expect(game.instance_variable_get(:@game_over)).to be false
    end

    it 'sets game over when no lives remain' do
      # Set lives to 1
      game.instance_variable_set(:@lives, 1)
      game.send(:handle_collision)
      expect(game.instance_variable_get(:@game_over)).to be true
      expect(game.instance_variable_get(:@running)).to be true
    end
  end

  describe 'collision detection' do
    it 'detects ceiling collision' do
      bird = game.instance_variable_get(:@bird)
      bird.instance_variable_set(:@y, Environment::CEILING_LEVEL - 1)
      game.instance_variable_set(:@countdown, nil)
      game.instance_variable_set(:@welcome_screen, false)
      game.send(:update)
      expect(game.instance_variable_get(:@lives)).to eq(2)
    end

    it 'detects floor collision' do
      bird = game.instance_variable_get(:@bird)
      bird.instance_variable_set(:@y, Environment::GROUND_LEVEL)
      game.instance_variable_set(:@countdown, nil)
      game.instance_variable_set(:@welcome_screen, false)
      game.send(:update)
      expect(game.instance_variable_get(:@lives)).to eq(2)
    end

    it 'detects obstacle collision' do
      bird = game.instance_variable_get(:@bird)
      obstacle = Obstacle.create_pair(Environment::SCREEN_WIDTH / 2)
      game.obstacles << obstacle
      bird.instance_variable_set(:@x, obstacle.x + 1)
      bird.instance_variable_set(:@y, Environment::CEILING_LEVEL + 1)
      game.instance_variable_set(:@countdown, nil)
      game.instance_variable_set(:@welcome_screen, false)
      game.send(:update)
      expect(game.instance_variable_get(:@lives)).to eq(2)
    end
  end

  describe 'scoring system' do
    it 'starts with 0 points' do
      expect(game.instance_variable_get(:@points)).to eq(0)
    end

    it 'increments points when bird clears an obstacle' do
      obstacle = Obstacle.create_pair(Environment::SCREEN_WIDTH / 2)
      game.obstacles << obstacle
      bird = game.instance_variable_get(:@bird)
      bird.instance_variable_set(:@x, obstacle.right_edge + 1)
      game.instance_variable_set(:@countdown, nil)
      game.instance_variable_set(:@welcome_screen, false)
      game.send(:update)
      expect(game.instance_variable_get(:@points)).to eq(1)
    end

    it 'removes obstacle after scoring' do
      obstacle = Obstacle.create_pair(Environment::SCREEN_WIDTH / 2)
      game.obstacles << obstacle
      bird = game.instance_variable_get(:@bird)
      bird.instance_variable_set(:@x, obstacle.right_edge + 1)
      game.instance_variable_set(:@countdown, nil)
      game.instance_variable_set(:@welcome_screen, false)
      game.send(:update)
      expect(game.obstacles).not_to include(obstacle)
    end

    it 'does not increment points if bird has not cleared obstacle' do
      # Add an obstacle
      obstacle = Obstacle.create_pair(Environment::SCREEN_WIDTH / 2)
      game.obstacles << obstacle

      # Position bird before the obstacle
      bird = game.instance_variable_get(:@bird)
      bird.instance_variable_set(:@x, obstacle.x - 1)

      # Update game to check points
      game.send(:update)
      expect(game.instance_variable_get(:@points)).to eq(0)
    end

    it 'persists points across lives' do
      obstacle = Obstacle.create_pair(Environment::SCREEN_WIDTH / 2)
      game.obstacles << obstacle
      bird = game.instance_variable_get(:@bird)
      bird.instance_variable_set(:@x, obstacle.right_edge + 1)
      game.instance_variable_set(:@countdown, nil)
      game.instance_variable_set(:@welcome_screen, false)
      game.send(:update)
      expect(game.instance_variable_get(:@points)).to eq(1)
      bird.instance_variable_set(:@y, Environment::CEILING_LEVEL - 1)
      game.instance_variable_set(:@countdown, nil)
      game.send(:update)
      expect(game.instance_variable_get(:@points)).to eq(1)
      expect(game.instance_variable_get(:@lives)).to eq(2)
    end
  end

  describe 'countdown system' do
    it 'starts with a 3 second countdown' do
      expect(game.instance_variable_get(:@countdown)).to eq(3)
    end

    it 'resets countdown after losing a life' do
      # Trigger a collision to lose a life
      bird = game.instance_variable_get(:@bird)
      bird.instance_variable_set(:@y, Environment::CEILING_LEVEL - 1)
      game.send(:update)

      # Countdown should be reset to 3
      expect(game.instance_variable_get(:@countdown)).to eq(3)
    end

    it 'decrements countdown' do
      game.instance_variable_set(:@countdown, 3)
      game.instance_variable_set(:@countdown, game.instance_variable_get(:@countdown) - 1)
      expect(game.instance_variable_get(:@countdown)).to eq(2)
    end

    it 'ends countdown when reaching zero' do
      game.instance_variable_set(:@countdown, 1)
      game.instance_variable_set(:@countdown, game.instance_variable_get(:@countdown) - 1)
      expect(game.instance_variable_get(:@countdown)).to eq(0)
      # Simulate the game loop setting countdown to nil after reaching 0
      if game.instance_variable_get(:@countdown) == 0
        game.instance_variable_set(:@countdown, nil)
      end
      expect(game.instance_variable_get(:@countdown)).to be_nil
    end

    it 'does not update game state during countdown' do
      # Add an obstacle
      obstacle = Obstacle.create_pair(Environment::SCREEN_WIDTH / 2)
      game.obstacles << obstacle

      # Position bird to clear the obstacle
      bird = game.instance_variable_get(:@bird)
      bird.instance_variable_set(:@x, obstacle.right_edge + 1)

      # Update game during countdown
      game.send(:update)

      # Points should not increment during countdown
      expect(game.instance_variable_get(:@points)).to eq(0)
    end
  end

  describe '#handle_input' do
    it 'starts game from welcome screen when space is pressed' do
      game.instance_variable_set(:@welcome_screen, true)
      game.handle_input(' ')
      expect(game.instance_variable_get(:@welcome_screen)).to be false
      expect(game.instance_variable_get(:@countdown)).to eq(3)
    end

    it 'resets game from game over screen when space is pressed' do
      game.instance_variable_set(:@game_over, true)
      game.instance_variable_set(:@points, 10)
      game.instance_variable_set(:@lives, 0)
      game.handle_input(' ')
      expect(game.instance_variable_get(:@game_over)).to be false
      expect(game.instance_variable_get(:@points)).to eq(0)
      expect(game.instance_variable_get(:@lives)).to eq(3)
    end

    it 'makes bird jump when space is pressed during gameplay' do
      game.instance_variable_set(:@welcome_screen, false)
      game.instance_variable_set(:@game_over, false)
      bird = game.instance_variable_get(:@bird)
      expect(bird).to receive(:jump)
      game.handle_input(' ')
    end

    it 'quits game when q is pressed' do
      game.handle_input('q')
      expect(game.instance_variable_get(:@running)).to be false
    end
  end

  describe '#update' do
    it 'does not update game state during welcome screen' do
      game.instance_variable_set(:@welcome_screen, true)
      game.instance_variable_set(:@countdown, nil)
      game.instance_variable_set(:@game_over, false)
      expect(game).not_to receive(:update_obstacles)
      game.send(:update)
    end

    it 'does not update game state during game over' do
      game.instance_variable_set(:@welcome_screen, false)
      game.instance_variable_set(:@countdown, nil)
      game.instance_variable_set(:@game_over, true)
      expect(game).not_to receive(:update_obstacles)
      game.send(:update)
    end
  end
end
