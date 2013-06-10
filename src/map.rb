#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "cell.rb"
require "sdl"

DEFAULT_RESUME="resume.rb"

class Map
  # A tile is a square of cells
  attr_reader :tiles
  attr_reader :cells
  attr_reader :texture
  attr_reader :skybox

  def initialize(path)
    @@PATH=path

    # Load the map resume
    if (File.exists?(path))
      require path + "/" + DEFAULT_RESUME
    else
      raise "Error : #{path} is not a valid directory !"
    end

    # Check if the given files are presents.
    unless (File.exists?(path + "/" + LEVEL_PATH))
      raise "Error : Cannot open the level file !"
    end
  end

  def source(system)
    system.print(2, 40, "Loading map : #{MAP_NAME}")
    puts "Loading map : #{MAP_NAME}"

    # Populate the map's cells
    buffer = File.open(@@PATH + "/" + LEVEL_PATH, 'rb'){ |io| io.read }

    # Getting the bmp informations
    size = buffer[2..5].unpack("L")[0]
    bmp_offset = buffer[10..13].unpack("L")[0]
    width = buffer[18..21].unpack("L")[0]
    length = buffer[22..25].unpack("L")[0]
    bits_per_pixel = buffer[28..29].unpack("S")[0]

    # Checking the bmp informations
    if (width != MAP_WIDTH || length != MAP_LENGHT)
      raise "Error : bad map size"
    end
    unless (bits_per_pixel == 24)
      raise "Error : bad definition for the image (should be 24bpp)"
    end

    system.print(2, 50, "Generating height map...")
    $stdout.print "Generating height map..."
    $stdout.flush

    # Create the cells array
    @cells = Array.new(width) { |x| Array.new(length) { |y| Cell.new(x, y) } }

    # Populate the cells array
    offset = bmp_offset
    step = 3
    width.times { |x|
      length.times { |y|
        @cells[x][y].height =
        ((buffer[offset] + buffer[offset + 1] + buffer[offset + 2]) / 3)  *
        MAX_HEIGHT / 0xff
        offset +=  step
      }
    }
    puts " done !"
    system.print(120, 50, " done !")

    # Generate the tile map
    $stdout.print "Generating tile map..."
    system.print(2, 60, "Generating tile map...")
    $stdout.flush
    unless (MAP_WIDTH % TILE_SIZE == 0 && MAP_LENGHT % TILE_SIZE == 0)
      raise "Error : Map size is not a multiple of the tile size"
    end
    tile_x = MAP_WIDTH / TILE_SIZE
    tile_y = MAP_LENGHT / TILE_SIZE
    Tile.set_step(TILE_SIZE)
    @tiles = Array.new(tile_x){ |x|
      Array.new(tile_y) { |y|
        Tile.new(x, y)
      }
    }
    puts " done !"
    system.print(120, 60, " done !")

    $stdout.print "Loading texture map..."
    system.print(2, 70, "Loading texture map...")
    $stdout.flush
    @texture = SDL::Surface.load_bmp(@@PATH + "/" + TEXTURE_PATH)
    puts " done !"
    system.print(120, 70, " done !")

    $stdout.print "Loading skybox map..."
    system.print(2, 80, "Loading skybox map...")
    $stdout.flush
    @skybox = SDL::Surface.load_bmp(@@PATH + "/" + SKYBOX_PATH)
    puts " done !"
    system.print(120, 80, " done !")
  end

end
