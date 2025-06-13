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
  end

  describe '#jump' do
    it 'sets velocity to jump force' do
      bird.jump
      expect(bird.velocity).to eq(-5)
    end
  end
end
