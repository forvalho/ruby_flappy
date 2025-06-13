class Environment
  # Physics constants
  GRAVITY = 0.5
  JUMP_FORCE = -3

  # Game timing
  FRAME_RATE = 0.1  # seconds per frame

  # Screen dimensions
  SCREEN_WIDTH = 80
  SCREEN_HEIGHT = 24

  # Game boundaries
  GROUND_LEVEL = 20
  CEILING_LEVEL = 1

  # Bird movement
  HORIZONTAL_SPEED = 1  # spaces per frame
  STARTING_X = 5        # starting horizontal position
  STARTING_Y = (GROUND_LEVEL - CEILING_LEVEL) / 2 + CEILING_LEVEL  # middle height
end
