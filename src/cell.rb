#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

class Cell
  attr_accessor :height
  attr_reader :x
  attr_reader :y

  def initialize(x, y)
    @height = 0
    @x = x
    @y = y
  end

end

class Tile
  attr_accessor :x1
  attr_accessor :x2
  attr_accessor :y1
  attr_accessor :y2
  attr_accessor :computed

  def initialize(offset_x, offset_y)
    @x1 = offset_x * @@step
    @x2 = @x1 + @@step - 1
    @y1 = offset_y * @@step
    @y2 = @y1 + @@step - 1
    @computed = false
  end

  def Tile.set_step(step)
    @@step = step
  end

  def Tile.get_tile(tiles_map, x, y)
    if (x < 0)
      x += MAP_WIDTH
    end
    if (y < 0)
      y += MAP_LENGHT
    end

    x %= MAP_WIDTH
    y %= MAP_LENGHT

    if (x < 0)
      x += MAP_WIDTH
    end
    if (y < 0)
      y += MAP_WIDTH
    end
    return tiles_map[x / @@step][y / @@step]
  end

  def get_cells(cells_map)
    return cells_map[@x1...@x2][@y1...@y2]
  end

end
