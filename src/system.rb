#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "sdl"

Key = Struct.new("Key", :left, :right, :up, :down, :space, :ctrl)
StoredTile = Struct.new("StoredTile", :tile, :distance, :offset_x, :offset_y)
White_Array= [ 0xff, 0xff, 0xff ]

class System
  attr_accessor :map
  attr_accessor :camera

  def initialize()
    SDL.init(SDL::INIT_VIDEO)
    SDL::TTF.init
    @font=SDL::TTF.open(FONT_PATH, 10)
    @font_title=SDL::TTF.open(FONT_PATH, 20)
    @font.style=SDL::TTF::STYLE_NORMAL

    # Compute the distance between the camera point and the real screen
    @screen_middle_hor = DISPLAY_WIDTH / 2
    @screen_middle_vert = DISPLAY_LENGHT / 2
    @camera_screen_dist = Integer(@screen_middle_hor / (Math.tan(FOV)))
    @camera_vertical_fov =
      Math.atan(@screen_middle_vert.fdiv(@camera_screen_dist)).abs

    # start the display screen
    @screen = SDL::setVideoMode(DISPLAY_WIDTH, DISPLAY_LENGHT,
                                DISPLAY_DEEP, SDL::SWSURFACE)
    @y_buffer = Array.new(DISPLAY_WIDTH)
    SDL::WM.setCaption(APP_NAME, APP_NAME)
  end

  def print(x, y, string)
    @font.drawSolidUTF8(@screen, string, x, y, *White_Array)
    @screen.flip
  end

  def print_title(string, authors)
    @font_title.drawSolidUTF8(@screen, string,
                              DISPLAY_WIDTH / 2 - string.size * 4,
                              10, *White_Array)
    @font.drawSolidUTF8(@screen, authors,
                        DISPLAY_WIDTH / 2 + string.size *
                        4 - authors.size * 2, 24, *White_Array)
    @screen.flip
  end

  def start
    puts "Starting the system"

    dt = 0
    key = Key.new
    curr_t = SDL::getTicks

    # Rendering loop
    while (true)
      # Getting input events
      event = SDL::Event2.poll
      if (event.class == SDL::Event::Quit)
        break
      end
      if (event.class == SDL::Event::KeyDown &&
          event.sym == SDL::Key::ESCAPE)
        break
      end

      SDL::Key::scan
      key.left = SDL::Key::press?(SDL::Key::LEFT)
      key.right = SDL::Key::press?(SDL::Key::RIGHT)
      key.up = SDL::Key::press?(SDL::Key::UP)
      key.down = SDL::Key::press?(SDL::Key::DOWN)
      key.space = SDL::Key::press?(SDL::Key::SPACE)
      key.ctrl = SDL::Key::press?(SDL::Key::LCTRL)

      # Getting elapsed time
      old_t = curr_t
      curr_t = SDL::getTicks
      dt = curr_t - old_t

      # Update camera pos
      @camera.update(key, dt)

      # Redraw the screen
      render()

      # actualize on screen informations
      @font.drawSolidUTF8(@screen,"render time : #{dt}",
                          2, 2, *White_Array)
      @font.drawSolidUTF8(@screen,
                          "x : #{camera.x} y : #{camera.y} z : #{camera.z}",
                          2, 12, *White_Array)
      @font.drawSolidUTF8(@screen,"a : #{camera.a}",
                          2, 22, *White_Array)

      # Display the new screen
      @screen.flip

    end
    puts "Stoping the system"
  end

  def render()
    # Get the current camera's tile
    camera_tile = Tile.get_tile(@map.tiles, @camera.x, @camera.y)

    # Now, determine wich tiles are visible
    tile_list = [ StoredTile.new(camera_tile, 0, 0, 0) ]
    camera_tile.computed = true

    @camera_angle = (@camera.a - FOV)
    @end_camera_angle = (@camera.a + FOV)

    angle = @camera_angle
    while (angle < @end_camera_angle)
      distance = 0
      while (distance < VIEW_DISTANCE)
        x = Integer(Math.cos(angle) * distance)
        y = Integer(Math.sin(angle) * distance)
        tile = Tile.get_tile(@map.tiles, x, y)
        unless (tile.computed)
          offset_x = x > MAP_WIDTH ? MAP_WIDTH : (x < 0 ? - MAP_WIDTH : 0)
          offset_y = y > MAP_WIDTH ? MAP_WIDTH : (y < 0 ? - MAP_WIDTH : 0)
          tile_list << StoredTile.new(tile, distance, offset_x, offset_y)
          tile.computed = true
        end
        distance += VIEW_STEP
      end
      angle += VIEW_SLICE_ANGLE
    end

    # Last, reset the computed flag of each tile
    tile_list.each { |curr|
      curr.tile.computed = false
    }

    # Clean the screen by drawing the skybox
#    @screen.fillRect(0, 0, DISPLAY_WIDTH, DISPLAY_LENGHT, SKY_COLOR)
    if (@camera.a < - (HALF_PI + QUARTER_PI))
      offset = Integer((@camera.a + PI).fdiv(2 * PI) * 1900)
    else
      if (@camera.a > HALF_PI + QUARTER_PI)

      else
        offset = Integer((@camera.a + PI).fdiv(2 * PI) * 1900)
        SDL::Surface.blit(@map.skybox, offset, 0,
                          320 + offset, 240, @screen, 0, 0)
      end
    end

    # Generate the y buffer
    0.upto(DISPLAY_WIDTH){ |i|
      @y_buffer[i] = DISPLAY_LENGHT
    }

    # Drawing the screen by using the tiles
    tile_list.each { |curr_tile|

      # Get the step we are going to use according with tile's distance
      step = curr_tile.distance / TILE_SIZE + 1

      # Camera angle is between 0 and 2 PI
      if (@camera.a < - (QUARTER_PI + HALF_PI) ||
          @camera.a > HALF_PI + QUARTER_PI)
        curr_tile.tile.x2.step(curr_tile.tile.x1, -step) { |x|
          curr_tile.tile.y1.step(curr_tile.tile.y2, step) { |y|
            draw_pxl(x, y, curr_tile, step)
          }
        }
      else
        if (@camera.a < - QUARTER_PI)
          curr_tile.tile.y2.step(curr_tile.tile.y1, -step) { |y|
            curr_tile.tile.x1.step(curr_tile.tile.x2, step) { |x|
              draw_pxl(x, y, curr_tile, step)
            }
          }
        else
          if (@camera.a < QUARTER_PI)
            curr_tile.tile.x1.step(curr_tile.tile.x2, step) { |x|
              curr_tile.tile.y1.step(curr_tile.tile.y2, step) { |y|
                draw_pxl(x, y, curr_tile, step)
              }
            }
          else
            curr_tile.tile.y1.step(curr_tile.tile.y2, step) { |y|
              curr_tile.tile.x1.step(curr_tile.tile.x2, step) { |x|
                draw_pxl(x, y, curr_tile, step)
              }
            }
          end
        end
      end
    }
  end

  def draw_pxl(x, y, curr_tile, step)
    # Get the current point's corresponding screen slice
    pixl_dist_x = curr_tile.offset_x + x - @camera.x
    pixl_dist_y = curr_tile.offset_y + y - @camera.y

    if (pixl_dist_x == 0)
      if (pixl_dist_y > 0)
        pixl_camera_angle = HALF_PI
      else
        pixl_camera_angle = - HALF_PI
      end
    else
      pixl_camera_angle = Math.atan(pixl_dist_y.fdiv(pixl_dist_x))
    end

    pixl_dist = Math.sqrt(pixl_dist_x ** 2 + pixl_dist_y ** 2)
    pixl_vert_angle_tan = (@map.cells[x][y].height -
                           @camera.z).fdiv(pixl_dist)
    pixl_vert_angle = Math.atan(pixl_vert_angle_tan)

    if (pixl_vert_angle.abs < @camera_vertical_fov)
      screen_offset_x =
        Math.tan(@camera.a - pixl_camera_angle) * @camera_screen_dist
      screen_x = Integer(@screen_middle_hor + screen_offset_x)
      if (screen_x > DISPLAY_WIDTH || screen_x < 0)
        return
      end
      screen_end_y = Integer(@screen_middle_vert -
                             pixl_vert_angle_tan *
                             @camera_screen_dist)
      if (screen_end_y < @y_buffer[screen_x])
        # Generate the distance's color
        color = @map.texture[x, y]
        @screen.fillRect(screen_x, screen_end_y, step,
                         @y_buffer[screen_x] - screen_end_y,
                         color)
        @y_buffer[screen_x] = screen_end_y
      end
    end
  end

end
