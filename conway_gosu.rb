require 'gosu'

class MainWindow < Gosu::Window

  CELL_SIZE = 20
  BORDER = 5

  def initialize(map_width, map_height)
    @map = seed_map map_width, map_height
    screen_width = CELL_SIZE * map_width + BORDER
    screen_height = CELL_SIZE * map_height + BORDER
    super screen_width, screen_height, false, 100
    self.caption = "Conways Game of Life"
    #@skull = Gosu::Image.new self,"skull_sprite_by_goodlyay-d6qf9nn.png",true
  end

  def update
    for_entire_map do |x,y|
      live x,y
    end
  end

  def draw
    for_entire_map do |x,y|
      draw_rect x,y
    end
  end

  private

  def for_entire_map(&block)
    @map.size.times do |map_y|
      @map[0].size.times do |map_x|
        block.call map_x,map_y
      end
    end
  end

  def draw_rect(map_x,map_y)
    x = map_x * CELL_SIZE + BORDER
    y = map_y * CELL_SIZE + BORDER
    size = CELL_SIZE
    color = @map[map_y][map_x] ? 0xffffffff : 0x00000000
    draw_quad x,y,color,x+size,y,color,x,y+size,color,x+size,y+size,color
  end

  def live(map_x,map_y)
    alive_neighbours = count_alive_neighbours map_x,map_y
    alive = @map[map_y][map_x]
    if alive then
      case
      when alive_neighbours < 2
        #Dies
        @map[map_y][map_x] = false
      when (2..3).cover?(alive_neighbours)
        #Lives on
      when alive_neighbours > 3
        #Dies
        @map[map_y][map_x] = false
      end
    else
      if alive_neighbours == 3 then
        #Revive
        @map[map_y][map_x] = true
        alive = true
      end
    end
    alive
  end

  def count_alive_neighbours(map_x,map_y)
    neighbours = [
      [-1, 1],[0, 1],[1, 1],
      [-1, 0],       [1, 0],
      [-1,-1],[0,-1],[1,-1]
    ]

    neighbours.map do |mod_x,mod_y|
      x = map_x + mod_x
      y = map_y + mod_y
      # Checking whether x and y are inside our map
      if (x >= 0 && y >= 0) && (x < @map[0].size && y < @map.size) then
        @map[y][x]
      else
        false
      end
    end.count(true)
  end

  def seed_map(width, height)
    ret = []
    height.times do
      ret << []
      width.times do
        ret[-1] << (rand(2) == 1) ? true : false
      end
    end
    return ret
  end

end

begin
  Float ARGV[0]
  Float ARGV[1]
rescue
  puts "Script takes to numbers for map width and height as parameters"
  puts "Got : #{ARGV}"
  exit 1
end
window = MainWindow.new Float(ARGV[0]).to_i, Float(ARGV[1]).to_i
window.show
