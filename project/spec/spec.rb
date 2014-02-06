require 'Matrix'

describe "Polygon" do
  VECTOR_ARRAY = [
      Vector[0, 0, 0],
      Vector[1.5, 2, 0],
      Vector[2, 4, 0],
      Vector[1.5, 6, 0],
      Vector[0, 8, 0],
    ].freeze

  it "creates Vector polygons" do
    poly = Polygon.new VECTOR_ARRAY
    poly.points.should eq VECTOR_ARRAY
  end

  it "retrieves exact point" do
    poly = Polygon.new VECTOR_ARRAY
    poly.get_point(2).should eq VECTOR_ARRAY[2]
  end

  it "adds a new point with :closest" do
    poly = Polygon.new VECTOR_ARRAY
    poly.add_point(Vector[1, 1, 0])
    poly.add_point(Vector[1, 7, 0])
    poly.points.should eq [
      Vector[0, 0, 0],
      Vector[1, 1, 0],
      Vector[1.5, 2, 0],
      Vector[2, 4, 0],
      Vector[1.5, 6, 0],
      Vector[1, 7, 0],
      Vector[0, 8, 0],
    ]
  end

  it "adds a new point with index" do
    poly = Polygon.new VECTOR_ARRAY
    poly.add_point(Vector[1, 1, 1], 1)
    poly.add_point(Vector[8, 9, 10], 5)
    poly.points.should eq [
      Vector[0, 0, 0],
      Vector[1, 1, 1],
      Vector[1.5, 2, 0],
      Vector[2, 4, 0],
      Vector[1.5, 6, 0],
      Vector[8, 9, 10],
      Vector[0, 8, 0],
    ]
  end
end

describe "Spline" do
  CONTROL_POINTS = [
      Vector[0, 0, 0],
      Vector[4, 4, 0],
      Vector[0, 8, 0],
    ].freeze

  it "creates splines properly from arrays" do
    poly = Polygon.new CONTROL_POINTS
    spline = Spline.new CONTROL_POINTS, 3
    spline.control_polygon.points.should eq poly.points
  end

  it "creates splines properly from polygons" do
    poly = Polygon.new CONTROL_POINTS
    spline = Spline.new poly, 3
    spline.control_polygon.points.should eq poly.points
  end

  it "calculates spline points properly" do
    spline = Spline.new CONTROL_POINTS, 3
    spline.get_precise_points(5).should eq [
      Vector[0, 0, 0],
      Vector[1.5, 2, 0],
      Vector[2, 4, 0],
      Vector[1.5, 6, 0],
      Vector[0, 8, 0],
    ]
  end
end

describe "Polygon Resolver" do
end

describe "Mesh" do
end

describe "Mesh Exporter" do
end