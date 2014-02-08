
require 'green_shoes'
require_relative '../core/utils.rb'
require_relative '../core/polygon.rb'
require_relative '../core/spline.rb'
require_relative '../core/revolver.rb'
require_relative '../core/mesh.rb'
require_relative '../core/mesh_generator.rb'
require_relative '../core/mesh_exporter.rb'

module Gui
  WINDOW_WIDTH = 1024
  WINDOW_HEIGHT = 768
  DRAW_AREA_WIDTH = 768
  PADDING = 10
  BUTTON_AREA_WIDTH = 100
  VERTEX_RADIUS = 6
  SELECTED_VERTEX_RADIUS = 8
end

Shoes.app title: "Revolved Objects creator", width: Gui::WINDOW_WIDTH, height: Gui::WINDOW_HEIGHT do

  def clear_draw_area
    background beige
    fill beige
    stroke beige
    rect 0, 0, self.width - Gui::BUTTON_AREA_WIDTH, self.height
    stroke dodgerblue
    strokewidth 3
    cap :curve
    line Gui::PADDING, Gui::PADDING, Gui::PADDING, self.height - Gui::PADDING
    line Gui::PADDING, self.height - Gui::PADDING, self.width - Gui::BUTTON_AREA_WIDTH - Gui::PADDING, self.height - Gui::PADDING
  end

  def draw_polygon
    clear_draw_area
    stroke blue
    strokewidth 3
    cap :curve
    @polygon.points.each_index do |index|
      line( @polygon.points[index][0], @polygon.points[index][1], @polygon.points[index - 1][0], @polygon.points[index - 1][1]) if index != 0
    end

    fill red
    @polygon.points.each do |point|
      oval left: point[0] - Gui::VERTEX_RADIUS, top: point[1] - Gui::VERTEX_RADIUS, radius: Gui::VERTEX_RADIUS
    end

    if @selected_point_index
      stroke yellow
      oval left: @polygon.points[@selected_point_index][0] - Gui::SELECTED_VERTEX_RADIUS, top: @polygon.points[@selected_point_index][1] - Gui::SELECTED_VERTEX_RADIUS, radius: Gui::SELECTED_VERTEX_RADIUS
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
      t += step
    end
  end

  def draw_final_points(points)
    stroke green
    points.each do |point|
      oval left: point[0] - 4, top: point[1] - 4, radius: 4
    end
  end

  #main
  @polygon = Polygon.new []
  @selected_point_index = nil

  draw_area = stack width: self.width - Gui::BUTTON_AREA_WIDTH, height: self.height do
    clear_draw_area
  end

  #mouse handling in draw area
  draw_area.click { |button, left, top|
    point = Vector[left, top, 0]
    case button
      when 1 #left click
        if @selected_point_index != nil
          @polygon.points[@selected_point_index] = point
          @selected_point_index = nil
        else
          if @polygon.include? point, Gui::VERTEX_RADIUS
            @selected_point_index = @polygon.find_index point, Gui::VERTEX_RADIUS
          else
            @polygon.add_point point
          end
        end
        draw_polygon
      when 3 #right click
        @selected_point_index = nil
        if @polygon.include? point, Gui::VERTEX_RADIUS
          index = @polygon.find_index point, Gui::VERTEX_RADIUS
          @polygon.remove_point index
        end
        draw_polygon
      else
        @selected_point_index = nil
    end
  }

  #spline = Spline.new poly, 4
  # n = spline.get_curves_count
  # 0.upto(n - 1).each do |curve_index|
  #   draw_bezier_curve(spline.get_curve_points curve_index)
  # end

  # draw_final_points(spline.get_precise_points(5))

  button('start') {draw_poly Polygon.new([Vector[20, 20, 0], Vector[40, 40, 0]])}.move 10, 200

end
