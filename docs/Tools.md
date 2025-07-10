# Auto-Grind Start/Stop

Attempts to grind on a surface's edge.

# Auto-Grind Divisor

Allows specifying the divisor for Mario's facing yaw. A lower value means a larger change in yaw.

# Auto-Grind Left/Right

Allows specifying the grind direction.

If Mario is grinding on the left side of a floor, select the left grind mode.

# Lookahead On/Off

Saves a state when enabled and frame advances until the specified depth is reached, at which point it loads the state again.

Allows previewing the result of movement changes in real-time; try this while testing GWK angles.

> [!WARNING]  
> Lookahead isn't compatible with savestate framebuffer restoration. Disable `Save video to savestates` in Mupen settings.

# Lookahead Depth

Allows specifying how many frames Lookahead displays before resetting to the previous state.

# Visualize Objects

Displays the hitboxes of objects.

# Auto-firsties

Presses A on the first frame of wallkicks.

# Minivisualizer

Displays a small encoding visualizer.

# Moved Distance

Tracks the distance Mario moved relative to his position when the button was pressed.

# Ignore Y

Ignores the Y component when computing the distance difference for Moved Distance.