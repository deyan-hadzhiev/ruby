module Graphics
  class Point
    attr_reader :x, :y

    def initialize(x, y)
      @x = x
      @y = y
    end

    def points
      [self]
    end

    def eql?(other_point)
      x == other_point.x and y == other_point.y
    end

    alias == eql?

    def hash
      "(#{x},#{y})".hash
    end
  end

  class Line
    attr_reader :from, :to

    def initialize(first, second)
      if first.x < second.x or (first.x == second.x and first.y < second.y)
        @from, @to = first, second
      else
        @from, @to = second, first
      end
    end

    def eql?(other_line)
      @from == other_line.from and @to == other_line.to
    end

    alias == eql?

    def hash
      "(#{@from.x},#{@from.y})-(#{@to.x},#{@to.y})".hash
    end

    def points
      bresenham(@from, @to)
    end

    private

    def bresenham(from, to)
      steep = (to.y - from.y).abs > (to.x - from.x).abs

      if steep then from, to = Point.new(from.y, from.x), Point.new(to.y, to.x) end
      if from.x > to.x then from, to = to, from end

      deltas = bresenham_calculate_delta_and_step(from, to)
      delta_x, delta_y, step_y = deltas[:delta_x], deltas[:delta_y], deltas[:step_y]

      bresenham_loop from.x, to.x, from.y, delta_x / 2, delta_x, delta_y, step_y, steep
    end

    def bresenham_loop(start_x, end_x, y, error, delta_x, delta_y, step_y, steep)
      start_x.upto(end_x).to_a.map do |x|
        point = steep ? Point.new(y, x) : Point.new(x, y)
        error -= delta_y
        if error <= 0
          y, error = y + step_y, error + delta_x
        end
        point
      end
    end

    def bresenham_calculate_delta_and_step(from, to)
      result = {}
      result[:delta_x] = to.x - from.x
      result[:delta_y] = (to.y - from.y).abs
      result[:step_y] = from.y < to.y ? 1 : -1
      result
    end
  end

  class Rectangle
    attr_reader :left, :right

    def initialize(first, second)
      if first.x < second.x or (first.x == second.x and first.y < second.y)
        @left, @right = first, second
      else
        @left, @right = second, first
      end
    end

    def top_left
      Point.new left.x, [left.y, right.y].min
    end

    def top_right
      Point.new right.x, [left.y, right.y].min
    end

    def bottom_left
      Point.new left.x, [left.y, right.y].max
    end

    def bottom_right
      Point.new right.x, [left.y, right.y].max
    end

    def eql?(other)
      top_left.eql? other.top_left and bottom_right.eql? other.bottom_right
    end

    alias == eql?

    def hash
      "(#{top_left.x},#{top_left.y}):(#{bottom_right.x},#{bottom_right.y})".hash
    end

    def points
      points = []
      points << horizontal_points(top_left, top_right)
      points << vertical_points(top_right, bottom_right)
      points << horizontal_points(bottom_left, bottom_right)
      points << vertical_points(top_left, bottom_left)
      points.flatten
    end

    private

    def horizontal_points(left, right)
      if left.y != right.y
        []
      else
        left.x.upto(right.x).to_a.map { |x| Point.new x, left.y }
      end
    end

    def vertical_points(top, bottom)
      if top.x != bottom.x
        []
      else
        top.y.upto(bottom.y).to_a.map { |y| Point.new top.x, y }
      end
    end
  end

  module Renderer
    class Generic
      class << self
        def render_canvas(canvas)
          canvas_matrix = Array.new (canvas.height) do |row|
            Array.new (canvas.width) { |column| canvas.pixel_at?(column, row) }
          end

          strings = canvas_matrix.map { |line| line.map { |pixel| render_pixel pixel } }
          strings = strings.map { |line| line.join }.join render_new_line
        end
      end
    end

    class Ascii < Generic
      HEADER = ""

      FOOTER = ""

      class << self
        def render_pixel(pixel)
          pixel ? "@" : "-"
        end

        def render_new_line
          "\n"
        end
      end
    end

    class Html < Generic
      HEADER =
        '<!DOCTYPE html>
            <html>
            <head>
              <title>Rendered Canvas</title>
              <style type="text/css">
                .canvas {
                  font-size: 1px;
                  line-height: 1px;
                }
                .canvas * {
                  display: inline-block;
                  width: 10px;
                  height: 10px;
                  border-radius: 5px;
                }
                .canvas i {
                  background-color: #eee;
                }
                .canvas b {
                  background-color: #333;
                }
              </style>
            </head>
            <body>
              <div class="canvas">
            '

      FOOTER =
        '
            </div>
          </body>
          </html>'

      class << self
        def render_pixel(pixel)
          pixel ? "<b></b>" : "<i></i>"
        end

        def render_new_line
          "<br>\n"
        end
      end
    end
  end

  class Canvas
    class OutOfBounds < StandardError
    end

    attr_reader :width, :height

    def initialize( width, height)
      @width = width
      @height = height
      @canvas = {}
      0.upto(height).each { |index| @canvas[index] = {} }
    end

    def set_pixel(x, y)
      @canvas[y][x] = true
    end

    def pixel_at?(x, y)
      @canvas[y][x].nil? ? false : true
    end

    def draw(object)
      points = object.points
      points.each { |point| set_pixel(point.x, point.y) }
    end

    def render_as(renderer)
      output = renderer::HEADER
      output << renderer.render_canvas(self)
      output << renderer::FOOTER
    end
  end
end