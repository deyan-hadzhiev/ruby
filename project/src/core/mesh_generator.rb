require 'Matrix'
require_relative '.\utils.rb'
require_relative '.\polygon.rb'
require_relative '.\spline.rb'
require_relative '.\revolver.rb'
require_relative '.\mesh.rb'

class MeshGenerator
  def initialize(polygon: polygon, precision: precision = 3, degree: degree = 4, rotations: rotations = 16)
    @poly = Polygon.new polygon
    @spline_precision = precision
    @spline_degree = degree
    @rotations = rotations
    normalize_polygon
  end

  attr_reader :poly
  attr_accessor :spline_precision, :spline_degree, :rotations

  def get_mesh
    precise_vertices = get_spline_vertices
    base_vertices = initialize_end_vertices precise_vertices
    revolved_vertices = get_revolved_vertices base_vertices
    mesh = Mesh.new revolved_vertices
    top_vertex_index = mesh.add_vertex @top_vertex
    bottom_vertex_index = mesh.add_vertex @bottom_vertex
    indices = get_revolved_indices base_vertices.length
    indices.concat PolygonIndiceCalculator.get_end_indices(top_vertex_index, bottom_vertex_index, base_vertices.length, @rotations)
    indices.each do |triangle|
      mesh.add_triangle triangle
    end
    mesh
  end

  #private

  def get_spline_vertices
    spline = Spline.new @poly, @spline_degree
    spline.get_precise_points(@spline_precision)
  end

  def get_revolved_vertices(base_vertices)
    result = []
    revolver = Revolver.new base_vertices
    angle_step = (Math::PI * 2) / @rotations
    current_angle = 0.0
    current_rotation = 0
    while current_rotation < @rotations do
      result.concat revolver.rotate_points(:y, current_angle)
      current_angle += angle_step
      current_rotation += 1
    end
    result
  end

  def normalize_polygon
    if @poly.points[0][1] < @poly.points[-1][1]
      @poly = Polygon.new @poly.points.reverse
    end
  end

  def initialize_end_vertices(base_vertices)
    result_vertices = base_vertices

    if result_vertices[0][0] == 0.0
      @top_vertex = result_vertices.delete_at(0)
    else
      @top_vertex = Vector[0.0, result_vertices[0][1], result_vertices[0][2]]
    end

    if result_vertices[-1][0] == 0.0
      @bottom_vertex = result_vertices.delete_at(-1)
    else
      @bottom_vertex = Vector[0.0, result_vertices[-1][1], result_vertices[-1][2]]
    end

    result_vertices
  end

  def get_revolved_indices(base_vertex_count)
    0.upto(@rotations - 1).reduce([]) do |result, rotation|
      indices = PolygonIndiceCalculator.get_indices(base_vertex_count, rotation)
      if rotation == @rotations - 1
        indices = PolygonIndiceCalculator.wrap_indices(indices, base_vertex_count * @rotations)
      end
      result.concat(indices)
    end
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

    def get_end_indices(top_index, bottom_index, vertex_count, rotations)
      top_indices = 0.upto(rotations - 1).reduce([]) do |result, index|
        result << [top_index, index * vertex_count, ((index + 1) % rotations) * vertex_count]
      end

      bottom_indices = 0.upto(rotations - 1).reduce([]) do |result, index|
        result << [bottom_index, ((index + 1) % rotations + 1) * vertex_count - 1, (index + 1) * vertex_count - 1]
      end

      top_indices + bottom_indices
    end
  end
end