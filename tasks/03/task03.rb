module Graphics
  #figures
  class Point
    attr_reader :x, :y

    def initialize(x, y)
      @x = x
      @y = y
    end

    def get_points
      [self]
    end

    def in_bounds?(width, height)
      x >= 0 and x < width and y >= 0 and y < height
    end

    def ==(other_point)
      eql? other_point
    end

    def eql?(other_point)
      x == other_point.x and y == other_point.y
    end

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

    def ==(other_line)
      eql? other_line
    end

    def hash
      "(#{@from.x},#{@from.y})-(#{@to.x},#{@to.y})".hash
    end

    def in_bounds?(width, height)
      @from.in_bounds?(width, height) and @to.in_bounds?(width, height)
    end

    def get_points
      bresenham(@from, @to)
    end

    def bresenham(from, to)
      steep = (to.y - from.y).abs > (to.x - from.x).abs
      if steep then from, to = Point.new(from.y, from.x), Point.new(to.y, to.x) end
      if from.x > to.x then from, to = to, from end
      delta_x, step_y = to.x - from.x, from.y < to.y ? 1 : -1
      delta_y = (to.y - from.y).abs
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

    private :bresenham, :bresenham_loop
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

    def ==(other)
      eql? other
    end

    def hash
      "(#{top_left.x},#{top_left.y}):(#{bottom_right.x},#{bottom_right.y})".hash
    end

    def in_bounds?(width, height)
      top_left.in_bounds?(width, height) and bottom_right.in_bounds?(width, height)
    end

    def get_points
      points = []
      points.concat get_horizontal_points(top_left, top_right)
      points.concat get_vertical_points(top_right, bottom_right)
      points.concat get_horizontal_points(bottom_left, bottom_right)
      points.concat get_vertical_points(top_left, bottom_left)
      points
    end

    def get_horizontal_points(left, right)
      if left.y != right.y
        []
      else
        left.x.upto(right.x).to_a.map { |x| Point.new x, left.y }
      end
    end

    def get_vertical_points(top, bottom)
      if top.x != bottom.x
        []
      else
        top.y.upto(bottom.y).to_a.map { |y| Point.new top.x, y }
      end
    end

    private :get_horizontal_points, :get_vertical_points
  end
end

module Graphics
  #renderers
  module Renderer
    class Generic
    end
    class Ascii < Generic
    end
    class Html < Generic
    end

    class << Generic
      def render(canvas)
        output = ""
        output << header
        output << render_canvas(canvas)
        output << footer
        output
      end

      def render_canvas(canvas)
        strings = canvas.map { |line| line.map { |pixel| render_pixel pixel } }
        strings = strings.map { |line| line.join }.join render_new_line
        strings
      end
    end

    class << Ascii
      def header
        ""
      end

      def footer
        ""
      end

      def render_pixel(pixel)
        pixel ? "@" : "-"
      end

      def render_new_line
        "\n"
      end
    end

    class << Html
      HTML_HEADER =
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

      HTML_FOOTER =
        '
          </div>
        </body>
        </html>'

      def header
        HTML_HEADER
      end

      def footer
        HTML_FOOTER
      end

      def render_pixel(pixel)
        pixel ? "<b></b>" : "<i></i>"
      end

      def render_new_line
        "<br>\n"
      end
    end
  end
end

module Graphics
  #canvas
  class Canvas
    class OutOfBounds < StandardError
    end

    attr_reader :width, :height

    def initialize( width, height)
      @width = width
      @height = height
      @canvas = Array.new(height) { Array.new(width) { false } }
    end

    def set_pixel(x, y)
      if x < 0 or x >= @width or y < 0 or y >= @height
        raise OutOfBounds, "Setting a pixel out of canvas' bounds."
      else
        @canvas[y][x] = true
      end
    end

    def pixel_at?(x, y)
      if x < 0 or x >= @width or y < 0 or y >= @height
        raise OutOfBounds, "Reaching a pixel out of canvas' bounds"
      else
        @canvas[y][x]
      end
    end

    def draw(object)
      if object.in_bounds?(width, height)
        points = object.get_points
        points.each { |point| set_pixel(point.x, point.y) }
      else
        raise OutOfBounds, "The object is out of canvas' bounds"
      end
    end

    def render_as(renderer)
      renderer.render(@canvas)
    end
  end
end