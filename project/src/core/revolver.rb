require 'Matrix'
require_relative './utils.rb'

class Revolver
  def initialize(points)
    @points = points
  end

  attr_reader :points

  def rotate_points(axis, angle)
    rotational_matrix = Transformations.get_rotational_matrix(axis, angle)
    @points.map { |point| rotational_matrix * point }
  end
end