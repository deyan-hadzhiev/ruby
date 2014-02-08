
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
  PADDING = 10
  BUTTON_AREA_WIDTH = 100
  VERTEX_RADIUS = 6
  SELECTED_VERTEX_RADIUS = 8
  CONTROL_VERTEX_RADIUS = 4
  BASE_CURVE_DRAW_STEP = 0.003
end

Shoes.app title: "Revolved Objects creator", width: Gui::WINDOW_WIDTH, height: Gui::WINDOW_HEIGHT do

  def clear_draw_area
    background lightgrey
    fill lightgrey
    stroke lightgrey
    rect 0, 0, self.width - Gui::BUTTON_AREA_WIDTH, self.height
    stroke dodgerblue
    strokewidth 3
    cap :curve
    line Gui::PADDING, Gui::PADDING, Gui::PADDING, self.height - Gui::PADDING
    line Gui::PADDING, self.height - Gui::PADDING, self.width - Gui::BUTTON_AREA_WIDTH - Gui::PADDING, self.height - Gui::PADDING
  end

  def redraw
    clear_draw_area
    draw_polygon
    spline = Spline.new @polygon, @spline_degree
    curves_count = spline.get_curves_count
    0.upto(curves_count - 1).each do |curve_index|
      draw_bezier_curve spline.get_curve_points(curve_index), Gui::BASE_CURVE_DRAW_STEP * @polygon.vertex_count
    end
    draw_final_points(spline.get_precise_points(@spline_precision))
  end

  def draw_polygon
    stroke blue
    strokewidth 3
    cap :curve
    @polygon.points.each_index do |index|
      line( @polygon.points[index][0], @polygon.points[index][1], @polygon.points[index - 1][0], @polygon.points[index - 1][1]) if index != 0
    end

    fill yellow
    @polygon.points.each do |point|
      oval left: point[0] - Gui::VERTEX_RADIUS, top: point[1] - Gui::VERTEX_RADIUS, radius: Gui::VERTEX_RADIUS
    end

    if @selected_point_index
      stroke yellow
      oval left: @polygon.points[@selected_point_index][0] - Gui::SELECTED_VERTEX_RADIUS, top: @polygon.points[@selected_point_index][1] - Gui::SELECTED_VERTEX_RADIUS, radius: Gui::SELECTED_VERTEX_RADIUS
    end
  end

  def draw_bezier_curve(points, draw_step)
    t = 0.0

    stroke red
    fill red
    strokewidth 3
    cap :curve

    coords = points.map { |point| point.to_a }.transpose
    while t < 1.0 do
      x_start = Spline.calculate_bezier_coordinate coords[0], t
      y_start = Spline.calculate_bezier_coordinate coords[1], t
      x_end = Spline.calculate_bezier_coordinate coords[0], t + draw_step
      y_end = Spline.calculate_bezier_coordinate coords[1], t + draw_step
      line x_start, y_start, x_end, y_end
      t += draw_step
    end
  end

  def draw_final_points(points)
    fill black
    stroke black
    points.each do |point|
      oval left: point[0] - Gui::CONTROL_VERTEX_RADIUS, top: point[1] - Gui::CONTROL_VERTEX_RADIUS, radius: Gui::CONTROL_VERTEX_RADIUS
    end
  end

  #main
  @polygon = Polygon.new []
  @selected_point_index = nil
  @spline_degree = 4
  @spline_precision = 5

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
        redraw
      when 3 #right click
        @selected_point_index = nil
        if @polygon.include? point, Gui::VERTEX_RADIUS
          index = @polygon.find_index point, Gui::VERTEX_RADIUS
          @polygon.remove_point index
        end
        redraw
      else
        @selected_point_index = nil
    end
  }

  button('start') {draw_poly Polygon.new([Vector[20, 20, 0], Vector[40, 40, 0]])}.move 10, 200

end
