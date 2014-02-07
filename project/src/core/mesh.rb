require 'Matrix'
require_relative '.\utils.rb'

class Mesh
  def initialize(vertices, triangles = [], normals = [])
    @vertices = vertices
    @triangles = triangles
    @normals = normals
    calculate_normals if @triangles.length != @normals.length
  end

  attr_reader :vertices, :triangles, :normals

  def add_vertex(vertex)
    @vertices << vertex
    @vertices.length - 1
  end

  def add_triangle(vertex_indices)
    @triangles << vertex_indices
    ab = @vertices[vertex_indices[1]] - @vertices[vertex_indices[0]]
    ac = @vertices[vertex_indices[2]] - @vertices[vertex_indices[0]]
    @normals << ab.cross_product(ac).normalize
    @triangles.length - 1
  end

  def calculate_normals
    @normals = []
    @triangles.each do |triangle|
      ab = @vertices[triangle[1]] - @vertices[triangle[0]]
      ac = @vertices[triangle[2]] - @vertices[triangle[0]]
      @normals << ab.cross_product(ac).normalize
    end
  end
end