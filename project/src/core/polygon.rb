require 'Matrix'
require_relative "./utils.rb"

class Polygon
  def initialize(array = [])
    if array.kind_of?(Polygon)
      @points = Array.new(array.points)
    else
      @points = Array.new(array)
    end
  end

  def get_point(index)
    @points[index]
  end

  def add_point(point, mode = :append, index = 0)
    case mode
      when :closest # insert the point at the closest position from the rest
        closest_index = find_closest_point point
        if @points.length > 0
          previous_distance = (@points[closest_index] - @points[closest_index - 1]).magnitude
          point_to_previous_distance = (point - @points[closest_index - 1]).magnitude
          closest_index = previous_distance > point_to_previous_distance ? closest_index : closest_index + 1
          closest_index = 1 if closest_index == 0 # it should not replace the first
        end
        @points.insert(closest_index, point)
      when :fixed
        if index >= 0 and index < @points.length
          @points.insert(index, point)
        end
      when :append
        @points << point
      else
        @points << point
    end
  end

  def include?(vertex, radius = 0)
    vectors = @points.map { |point| point - vertex }
    vectors.any? {|vector| vector.magnitude <= radius + Constants::EPS }
  end

  def find_index(vertex, radius = 0)
    vectors = @points.map { |point| point - vertex }
    vectors.find_index { |vector| vector.magnitude <= radius + Constants::EPS }
  end

  def remove_point(index)
    @points.delete_at(index)
  end

  def vertex_count()
    @points.length
  end

  attr_accessor :points

  private

  def find_closest_point(point)
    closest_index = 0
    if @points.length > 0
      minimal_distance = (@points[0] - point).magnitude
      @points.each_index do |point_index|
        if (@points[point_index] - point).magnitude < minimal_distance
          minimal_distance = (@points[point_index] - point).magnitude
          closest_index = point_index
        end
      end
    end
    closest_index
  end
end