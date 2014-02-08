require 'Matrix'
require_relative './utils.rb'
require_relative './polygon.rb'

class Spline
  def initialize(initial_points, degree = 3)
    if initial_points.kind_of?(Polygon)
      @control_polygon = Polygon.new(initial_points.points)
    else
      @control_polygon = Polygon.new(initial_points)
    end
    @degree = (degree >= MIN_DEGREE and degree <= MAX_DEGREE) ? degree : MIN_DEGREE
  end

  def get_precise_points(precision)
    precise_points = []
    curves = get_curves_count
    if curves > 0
      0.upto(curves - 1).each do |curve_index|
        precise_points.concat Spline.get_bezier_points(get_curve_points(curve_index), precision)
      end
      precise_points << @control_polygon.points[-1]
    else
      []
    end
  end

  attr_reader :control_polygon
  attr_accessor :degree

  def get_curve_points(curve_index)
    if curve_index < get_curves_count
      @control_polygon.points.slice(curve_index * (@degree - 1), @degree)
    end
  end

  def get_curves_count()
    full_curves = (@control_polygon.vertex_count - 1) / (@degree - 1)
    additional_curves = ((@control_polygon.vertex_count - 1) % (@degree - 1) > 0) ? 1 : 0
    full_curves + additional_curves
  end

  MIN_DEGREE = 2
  MAX_DEGREE = 5

  class << self
    def get_bezier_points(points, precision)
      result_points = []
      t = 0.0
      step = 1.0 / precision
      coordinate_arrays = points.map { |point| point.to_a }.transpose
      while t < 1.0 do
        x = calculate_bezier_coordinate(coordinate_arrays[0], t)
        y = calculate_bezier_coordinate(coordinate_arrays[1], t)
        result_points << Vector[x, y, 0.0]
        t += step
      end
      result_points
    end

    def calculate_bezier_coordinate(coordinates, t)
      t = 1.0 if t > 1.0
      degree = coordinates.length - 1
      indices = 0.upto(degree).to_a
      indices.reduce(0.0) do |result, index|
        result += Combinatorics.bernstein(degree, index, t) * coordinates[index]
      end
    end
  end
end