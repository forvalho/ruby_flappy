require_relative '../lib/game'

RSpec.describe Game do
  let(:game) { Game.new }

  describe '#initialize' do
    it 'starts with an empty obstacles array' do
      expect(game.obstacles).to be_empty
    end

    it 'initializes last_obstacle_x to screen width' do
      expect(game.last_obstacle_x).to eq(Environment::SCREEN_WIDTH)
    end
  end

  describe '#update_obstacles' do
    before do
      game.obstacles << Obstacle.new(10, 5)
      game.obstacles << Obstacle.new(20, 5)
    end

    it 'moves all obstacles left' do
      initial_x_positions = game.obstacles.map(&:x)
      game.send(:update_obstacles)
      new_x_positions = game.obstacles.map(&:x)

      new_x_positions.each_with_index do |new_x, i|
        expect(new_x).to eq(initial_x_positions[i] - Environment::HORIZONTAL_SPEED)
      end
    end

    it 'removes obstacles that go off screen' do
      game.obstacles << Obstacle.new(-1, 5)  # Off screen obstacle
      game.send(:update_obstacles)
      expect(game.obstacles.any? { |obs| obs.x < 0 }).to be false
    end
  end

  describe '#maybe_add_obstacle' do
    context 'when there are no obstacles' do
      before { game.obstacles.clear }
      it 'adds a pair of obstacles' do
        expect {
          game.send(:maybe_add_obstacle)
        }.to change { game.obstacles.size }.by(2)
      end
    end

    context 'when enough space has passed' do
      before do
        game.obstacles.clear
        # Place a rightmost obstacle far enough from the right edge
        game.obstacles << Obstacle.new(Environment::SCREEN_WIDTH - 10, 5)
      end

      it 'adds a pair of obstacles if distance is enough' do
        allow_any_instance_of(Object).to receive(:rand).and_return(5)
        expect {
          game.send(:maybe_add_obstacle)
        }.to change { game.obstacles.size }.by(2)
      end

      it 'adds obstacles at ceiling and ground level' do
        allow_any_instance_of(Object).to receive(:rand).and_return(5)
        game.send(:maybe_add_obstacle)
        new_obstacles = game.obstacles.last(2)
        expect(new_obstacles.map(&:y)).to contain_exactly(
          Environment::CEILING_LEVEL,
          Environment::GROUND_LEVEL
        )
      end

      it 'adds obstacles at screen width' do
        allow_any_instance_of(Object).to receive(:rand).and_return(5)
        game.send(:maybe_add_obstacle)
        new_obstacles = game.obstacles.last(2)
        expect(new_obstacles.map(&:x)).to all(eq(Environment::SCREEN_WIDTH))
      end
    end

    context 'when not enough space has passed' do
      before do
        game.obstacles.clear
        # Place a rightmost obstacle close to the right edge
        game.obstacles << Obstacle.new(Environment::SCREEN_WIDTH - 2, 5)
      end

      it 'does not add new obstacles if distance is not enough' do
        allow_any_instance_of(Object).to receive(:rand).and_return(5)
        expect {
          game.send(:maybe_add_obstacle)
        }.not_to change { game.obstacles.size }
      end
    end
  end
end
