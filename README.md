Garden
======

This is a little command line garden sim I wrote as a project to get more familiar with Elixir. To run it, just do `mix run --no-halt` in the project directory. You'll want to use a terminal which is capable of displaying Emojis. Hit Ctrl-C twice to exit.

The basics:

 * Type `help` for a list of commands.
 * You start with $10 to start buying seeds.
 * Plants will start dying if:
   * They don't have enough water.
   * They have too much water.
   * They are over-ripened.
 * If you keep a plant alive long enough to ripen, you can sell it. The price you get is determined by the health of the plant.
