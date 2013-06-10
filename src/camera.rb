#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

VERTICAL_SPEED=0.1
HORIZONTAL_SPEED=0.1
ROTATE_SPEED=0.0005

class Camera
  attr_accessor :x
  attr_accessor :y
  attr_accessor :z
  attr_accessor :a
  attr_accessor :b
  attr_accessor :c

  def initialize(x, y, z, a, b, c)
    @x = x
    @y = y
    @z = z
    @a = a
    @b = b
    @c = c
  end

  def update(key, dt)
    if (key.up)
      @x += Integer(Math.cos(@a) * HORIZONTAL_SPEED * dt)
      @y += Integer(Math.sin(@a) * HORIZONTAL_SPEED * dt)
      @x %= MAP_WIDTH
      @y %= MAP_LENGHT
    end
    if (key.down)
      @x -= Integer(Math.cos(@a) * HORIZONTAL_SPEED * dt)
      @y -= Integer(Math.sin(@a) * HORIZONTAL_SPEED * dt)
      @x %= MAP_WIDTH
      @y %= MAP_LENGHT
      if (@x < 0)
        @x += MAP_WIDTH
      end
      if (@y < 0)
        @y += MAP_LENGHT
      end
    end
    if (key.right)
      @a -= ROTATE_SPEED * dt
      if  (@a < - PI)
        @a += TWO_PI
      end
    end
    if (key.left)
      @a += ROTATE_SPEED * dt
      if  (@a > PI)
        @a -= TWO_PI
      end
    end
    if (key.space)
      @z += VERTICAL_SPEED * dt
      if (@z > CAMERA_MAX_HEIGHT)
        @z = CAMERA_MAX_HEIGHT
      end
    end
    if (key.ctrl)
      @z -= VERTICAL_SPEED * dt
      if (@z < MIN_HEIGHT)
        @z = MIN_HEIGHT
      end
    end
  end

  def visible?(x,y)
    # Add an offset if the given coordonates are negatives
    x %= MAP_WIDTH
    y %= MAP_LENGHT
    if (x < 0)
      x += MAP_WIDTH
    end
    if (y < 0)
      y += MAP_LENGHT
    end

    unless (PANZERSTCHROUMPH)
      # First check if the point is close enough
      if (((x - @x) ** 2 + (y - @y) ** 2) > VIEW_DISTANCE_POW)
        return false
      end
    end

    if (x == @x)
      unless (y == @y)
        angle = ((y - @y) < 0 ? (3 * PI/2) : (PI/2))
      else
        return true
      end
    else
      angle = Math.atan((y - @y).fdiv(x - @x))
    end
      puts "#{x} #{y} #{angle}"
    if (angle < (@a - FOV) || angle > (@a + FOV))
      return false
    end

    return true
  end

end
