class Environment
  # Physics constants
  GRAVITY = 0.5
  JUMP_FORCE = -2

  # Game timing
  FRAME_RATE = 0.1  # seconds per frame

  # Screen dimensions
  SCREEN_WIDTH = 80
  SCREEN_HEIGHT = 24

  # Game boundaries
  GROUND_LEVEL = 20
  CEILING_LEVEL = 1
  GROUND_VISUAL_LEVEL = GROUND_LEVEL + 1  # Where the green line appears

  # Bird movement
  HORIZONTAL_SPEED = 1  # spaces per frame
  STARTING_X = 5        # starting horizontal position
  STARTING_Y = (GROUND_LEVEL - CEILING_LEVEL) / 2 + CEILING_LEVEL  # middle height

  # Obstacle properties
  OBSTACLE_WIDTH = 6
  OBSTACLE_MIN_HEIGHT = 4
  OBSTACLE_GAP = 8
  OBSTACLE_MIN_SPACING = 5  # Minimum space between obstacles
  OBSTACLE_MAX_SPACING = 40  # Maximum space between obstacles
end
