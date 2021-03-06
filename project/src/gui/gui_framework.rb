
require 'green_shoes'
require_relative '../core/utils.rb'
require_relative '../core/polygon.rb'
require_relative '../core/spline.rb'
require_relative '../core/revolver.rb'
require_relative '../core/mesh.rb'
require_relative '../core/mesh_generator.rb'
require_relative '../core/mesh_exporter.rb'
require_relative '../misc/raytracer.rb'

module Gui
  WINDOW_WIDTH = 1024
  WINDOW_HEIGHT = 768
  PADDING = 10
  BUTTON_AREA_WIDTH = 100
  VERTEX_RADIUS = 6
  SELECTED_VERTEX_RADIUS = 8
  CONTROL_VERTEX_RADIUS = 4
  BASE_CURVE_DRAW_STEP = 0.003
  BUTTON_WIDTH = 80
  BUTTON_HEIGHT = 30
  TEXT_HEIGHT = 20
  TEXT_SIZE = 12
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

  def export_mesh
    reversed_polygon = Polygon.new @polygon.points.map { |vertex| Vector[ (vertex[0] - Gui::PADDING) * 0.1, (Gui::WINDOW_HEIGHT - Gui::PADDING - vertex[1]) * 0.1, vertex[2] * 0.1] }
    mesh_generator = MeshGenerator.new polygon: reversed_polygon, degree: @spline_degree, precision: @spline_precision, rotations: @rotations
    mesh = mesh_generator.get_mesh
    mesh_exporter = MeshExporter.new mesh
    mesh_exporter.export @export_filename
  end

  def start_raytracer
    Raytracer.copy_obj_file @object_filename
    Raytracer.create_scene @object_filename
    Raytracer.start_raytracer
  end

  def draw_add_mode_indicator
    x = self.width - Gui::BUTTON_AREA_WIDTH / 2 + Gui::BUTTON_WIDTH / 2 - 5
    y = Gui::BUTTON_HEIGHT + Gui::TEXT_HEIGHT + Gui::PADDING * 3 + Gui::BUTTON_HEIGHT / 2
    if @add_mode == :closest then
      fill green
      stroke green
    else
      fill red
      stroke red
    end
    oval x - 5, y -5, radius: 5
  end

  #main
  @polygon = Polygon.new []

  @selected_point_index = nil
  @add_mode = :append
  @spline_degree = 4
  @spline_precision = 5
  @rotations = 8
  @export_filename = "test.obj"
  @object_filename = "test.obj"

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
            @polygon.add_point point, @add_mode
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

  button_area = stack left: self.width - Gui::BUTTON_AREA_WIDTH, width: Gui::BUTTON_AREA_WIDTH, height: self.height do
    background darkgray
    button_clear = button "Clear", width: Gui::BUTTON_WIDTH, height: Gui::BUTTON_HEIGHT do
      @polygon = Polygon.new []
      redraw
    end

    label_add_mode = banner "Add Mode"
    label_add_mode.style size: Gui::TEXT_SIZE

    button_add_mode = button "Closest?", width: Gui::BUTTON_WIDTH - 15, height: Gui::BUTTON_HEIGHT do
      @add_mode = (@add_mode == :append ? :closest : :append)
      draw_add_mode_indicator
    end

    label_precision = banner "Precision"
    label_precision.style size: Gui::TEXT_SIZE

    edit_precision = edit_line width: Gui::BUTTON_WIDTH, text: @spline_precision.to_s do |self_obj|
      unless self_obj.text.empty?
        @spline_precision = self_obj.text.to_i
        redraw
      end
    end

    label_degree = banner "Degree"
    label_degree.style size: Gui::TEXT_SIZE

    edit_degree = edit_line width: Gui::BUTTON_WIDTH, text: @spline_degree.to_s do |self_obj|
      unless self_obj.text.empty?
        @spline_degree = self_obj.text.to_i
        redraw
      end
    end

    label_rotations = banner "Rotations"
    label_rotations.style size: Gui::TEXT_SIZE

    edit_rotations = edit_line width: Gui::BUTTON_WIDTH, text: @rotations.to_s do |self_obj|
      unless self_obj.text.empty?
        @rotations = self_obj.text.to_i
      end
    end

    label_export = banner "Export"
    label_export.style size: Gui::TEXT_SIZE

    edit_export = edit_line width: Gui::BUTTON_WIDTH, text: @export_filename do |self_obj|
      @export_filename = self_obj.text
    end

    button_export = button "Export", width: Gui::BUTTON_WIDTH, height: Gui::BUTTON_HEIGHT do
      export_mesh
    end

    label_show = banner "Show"
    label_show.style size: Gui::TEXT_SIZE

    edit_show = edit_line width: Gui::BUTTON_WIDTH, text: @object_filename do |self_obj|
      @object_filename = self_obj.text
    end

    button_show = button "Show", width: Gui::BUTTON_WIDTH, height: Gui::BUTTON_HEIGHT do
      start_raytracer
    end

    x_destination = self.width - Gui::BUTTON_WIDTH - Gui::PADDING
    y_destination = Gui::PADDING

    button_clear.move x_destination, y_destination
    y_destination += Gui::BUTTON_HEIGHT + Gui::PADDING
    label_add_mode.move x_destination, y_destination
    y_destination += Gui::TEXT_HEIGHT + Gui::PADDING
    button_add_mode.move x_destination, y_destination
    y_destination += Gui::BUTTON_HEIGHT + Gui::PADDING * 2
    label_precision.move x_destination, y_destination
    y_destination += Gui::TEXT_HEIGHT + Gui::PADDING
    edit_precision.move x_destination, y_destination
    y_destination += Gui::BUTTON_HEIGHT + Gui::PADDING
    label_degree.move x_destination, y_destination
    y_destination += Gui::TEXT_HEIGHT + Gui::PADDING
    edit_degree.move x_destination, y_destination
    y_destination += Gui::BUTTON_HEIGHT + Gui::PADDING
    label_rotations.move x_destination, y_destination
    y_destination += Gui::TEXT_HEIGHT + Gui::PADDING
    edit_rotations.move x_destination, y_destination
    y_destination += Gui::BUTTON_HEIGHT + Gui::PADDING * 3

    label_export.move x_destination, y_destination
    y_destination += Gui::TEXT_HEIGHT + Gui::PADDING
    edit_export.move x_destination, y_destination
    y_destination += Gui::BUTTON_HEIGHT + Gui::PADDING
    button_export.move x_destination, y_destination
    y_destination += Gui::BUTTON_HEIGHT + Gui::PADDING * 2

    label_show.move x_destination, y_destination
    y_destination += Gui::TEXT_HEIGHT + Gui::PADDING
    edit_show.move x_destination, y_destination
    y_destination += Gui::BUTTON_HEIGHT + Gui::PADDING
    button_show.move x_destination, y_destination

    draw_add_mode_indicator

  end

end
