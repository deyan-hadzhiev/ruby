require 'Matrix'
require_relative '.\utils.rb'
require_relative '.\spline.rb'
require_relative '.\revolver.rb'
require_relative '.\mesh.rb'

class MeshGenerator
  def initialize(polygon: control_points, precision: prec = 3, degree: deg = 4, rotations: rots = 16)
    @poly = Poly.new control_points
    @spline_precision = prec
    @spline_degree = deg
    @rotations = rots
  end
end

class PolygonIndiceCalculator
  class << self
    def get_indices(vertex_count, offset = 0)
      offset *= vertex_count
      0.upto(vertex_count - 2).reduce([]) do |output, index|
        output << [offset + index, offset + index + 1, offset + vertex_count + index]
        output << [offset + index + 1, offset + vertex_count + index + 1, offset + vertex_count + index]
      end
    end

    def wrap_indices(indices, total_count)
      indices.map do |triangle|
        triangle.map { |index| index % total_count } 
      end
    end
  end
end