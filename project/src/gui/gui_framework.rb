
require 'green_shoes'
require_relative '../core/polygon.rb'
require_relative '../core/spline.rb'

def init
  Polygon.new [
    Vector[50, 50, 0],
    Vector[250, 50, 0],
    Vector[50, 250, 0],
    Vector[250, 250, 0],
    Vector[50, 250, 0],
    Vector[250, 450, 0],
    Vector[50, 450, 0],
    Vector[600, 410, 0],
    Vector[700, 490, 0],
    Vector[670, 580, 0],
  ]
end

def draw_poly(poly)
  stroke blue
  strokewidth 3
  cap :curve
  poly.points.each_index do |index|
    line( poly.points[index][0], poly.points[index][1], poly.points[index - 1][0], poly.points[index - 1][1]) if index != 0
  end

  fill green
  poly.points.each do |point|
    oval left: point[0] - 5, top: point[1] - 5, radius: 5
  end
end

def draw_bezier_curve(points)
  t = 0.0
  step = 0.005

  stroke red
  fill red
  strokewidth 3

  coords = points.map { |point| point.to_a }.transpose

  while t < 1.0 do

    x = Spline.calculate_bezier_coordinate(coords[0], t)
    y = Spline.calculate_bezier_coordinate(coords[1], t)
    oval x - 2, y - 2, radius: 2
    # l = bezier(poly, t, t + step + 0.005)
    # line l[0][0], l[0][1], l[1][0], l[1][1], stokewidth: 3
    t += step
  end
end

def draw_final_points(points)
  stroke green
  points.each do |point|
    oval left: point[0] - 4, top: point[1] - 4, radius: 4
  end
end

Shoes.app title: "Revolved Objects creator", width: 1024, height: 768 do
  poly = init

  draw_poly(poly)

  spline = Spline.new poly, 4
  n = spline.get_curves_count
  0.upto(n - 1).each do |curve_index|
    draw_bezier_curve(spline.get_curve_points curve_index)
  end

  draw_final_points(spline.get_precise_points(5))

end