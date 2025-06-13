require_relative '../lib/bird'

RSpec.describe Bird do
  let(:bird) { Bird.new }

  describe '#initialize' do
    it 'starts at position 10' do
      expect(bird.position).to eq(10)
    end

    it 'starts with zero velocity' do
      expect(bird.velocity).to eq(0)
    end

    it 'starts with wings up' do
      expect(bird.to_s).to eq('=^o>')
    end
  end

  describe '#update' do
    it 'increases velocity due to gravity' do
      initial_velocity = bird.velocity
      bird.update
      expect(bird.velocity).to be > initial_velocity
    end

    it 'changes position based on velocity' do
      initial_position = bird.position
      bird.update
      expect(bird.position).to be > initial_position
    end

    it 'keeps wings up when not jumping' do
      bird.update
      expect(bird.to_s).to eq('=^o>')
    end
  end

  describe '#jump' do
    it 'sets velocity to jump force' do
      bird.jump
      expect(bird.velocity).to eq(-5)
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
