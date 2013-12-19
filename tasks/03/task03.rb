# task 03 - renderer

module Graphics
  #Figures
  class Point
    attr_reader :x, :y

    def initialize(x, y)
      @x = x
      @y = y
      self
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
    attr_reader :from, :to, :points

    def initialize(first, second)
      if first.x < second.x or (first.x == second.x and first.y < second.y)
        @from, @to = first, second
      else
        @from, @to = second, first
      end
      @points = []
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
      @points
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
      start_x.upto(end_x).each do |x|
        steep ? plot(Point.new y, x) : plot(Point.new x, y)
        error -= delta_y
        if error < 0
          y += step_y
          error += delta_x
        end
      end
    end

    def plot(point)
      @points << point
    end
    
    private :bresenham, :plot
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
            <div class="canvas">'

      HTML_FOOTER =
        ' </div>
        </body>
        </html>'

      private_constant :HTML_FOOTER, :HTML_HEADER

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
        "<br>"
      end
    end
  end
end

module Graphics
  #canvas
  class Canvas
    class OutOfBounds < StandardError
    end

    attr_reader :width, :height, :canvas

    def initialize( width, height)
      @width = width
      @height = height
      @canvas = Array.new(height){ Array.new(width) { false } }
    end

    def set_pixel(x, y)
      if x >= @width or y >= @height
        raise OutOfBounds, "Setting a pixel out of canvas' bounds."
      else
        @canvas[y][x] = true
      end
    end

    def pixel_at?(x, y)
      if x >= @width or y >= @height
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

class FileOutput
  def self.out(file, output_string)
    output = File.open file, "w"
    output << output_string
    output.close
  end
end