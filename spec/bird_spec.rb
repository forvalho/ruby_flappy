require_relative '../lib/bird'

RSpec.describe Bird do
  let(:bird) { Bird.new }

  describe '#initialize' do
    it 'starts at middle height' do
      expect(bird.y).to eq(Environment::STARTING_Y)
    end

    it 'starts at left side' do
      expect(bird.x).to eq(Environment::STARTING_X)
    end

    it 'starts with zero vertical speed' do
      expect(bird.vertical_speed).to eq(0)
    end

    it 'starts with wings up' do
      expect(bird.to_s).to eq('=^o>')
    end
  end

  describe '#update' do
    it 'increases vertical speed due to gravity' do
      initial_speed = bird.vertical_speed
      bird.update
      expect(bird.vertical_speed).to be > initial_speed
    end

    it 'changes y position based on vertical speed' do
      initial_y = bird.y
      bird.update
      expect(bird.y).to be > initial_y
    end

    it 'keeps wings up when not jumping' do
      bird.update
      expect(bird.to_s).to eq('=^o>')
    end
  end

  describe '#jump' do
    it 'sets vertical speed to jump force' do
      bird.jump
      expect(bird.vertical_speed).to eq(-2)
    end

    it 'puts wings down when jumping' do
      bird.jump
      expect(bird.to_s).to eq('=vo>')
    end

    it 'returns wings to up position after animation timer' do
      bird.jump
      3.times { bird.update }  # Wait for wing timer to reach 0
      bird.update              # One more update to actually change wing state
      expect(bird.to_s).to eq('=^o>')
    end
  end
end
