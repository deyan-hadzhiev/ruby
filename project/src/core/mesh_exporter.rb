require 'Matrix'
require_relative '.\utils.rb'
require_relative '.\mesh.rb'

class MeshExporter
  def initialize(mesh)
    @mesh = mesh
  end

  def export(filename)
    vertices = get_vertices_output
    normals = get_normals_output
    triangles = get_triangles_output

    File.open(filename, "w") do |file|
      vertices.each { |vertex| file.puts vertex }
      normals.each { |normal| file.puts normal }
      triangles.each { |triangle| file.puts triangle }
    end
    nil
  end

  private

  def get_vertices_output
    @mesh.vertices.reduce([]) do |output, vertex|
      output << ("v %.6f %.6f %.6f" % vertex.to_a)
    end
  end

  def get_normals_output
    @mesh.normals.reduce([]) do |output, normal|
      output << ("vn %.6f %.6f %.6f" % normal.to_a)
    end
  end

  def get_triangles_output
    normal_index = 0
    @mesh.triangles.reduce([]) do |output, triangle|
      arguments = triangle.map { |index| index + 1 } #the triangle indices are kept 0-based, but the file format is done in 1-based triangles
      normal_index += 1
      output << ("f %d//%d %d//%d %d//%d" % [arguments[0], normal_index, arguments[1], normal_index, arguments[2], normal_index])
    end
  end
end