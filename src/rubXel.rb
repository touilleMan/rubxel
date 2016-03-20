#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require_relative "map"
require_relative "camera"
require_relative "system"

APP_NAME="RubXel"
DEFAULT_PATH="../ressources/default"
FONT_PATH="../ressources/font.ttf"

if __FILE__ == $0
  # Load the resume file
  if (ARGV.size == 0)
    map = Map.new(DEFAULT_PATH)
  else
    map = Map.new(ARGV[0])
  end

  # initialize the system
  system = System.new

  puts "Starting RubXel"
  system.print_title(" --- RubXel 0.1 --- ", "by G.bleu")

  # Generate the map
  map.source(system)

  # Create a camera
  camera = Camera.new(START_X,
                      START_Y,
                      START_Z,
                      START_A,
                      START_B,
                      START_C)

  # Start the simulation
  system.map = map
  system.camera = camera
  system.start
end
