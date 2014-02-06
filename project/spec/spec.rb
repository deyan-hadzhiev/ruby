require 'Matrix'

describe "Utilities" do
  it "calculate factorials (small)" do
    Combinatorics.factorial(5).should eq 120
  end

  it "calculate factorials (big)" do
    Combinatorics.factorial(42).should eq 1405006117752879898543142606244511569936384000000000
  end

  it "calculate binomial (small)" do
    Combinatorics.binomial(5,2).should eq 10
  end

  it "calculate binomial (big)" do
    Combinatorics.binomial(73, 23).should eq 5685248339583664176
  end

  it "calculate bernstein values 1" do
    Combinatorics.bernstein(0, 0, 1).should eq 1.0
  end

  it "calculate bernstein values 2" do
    Combinatorics.bernstein(1, 0, 0.6).should eq 0.4
  end

  it "calculate bernstein values 3" do
    Combinatorics.bernstein(2, 1, 0.6).should eq 0.48
  end
end

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

  COTROL_POINTS_EXT = [
      Vector[0, 0, 0],
      Vector[4, 0, 0],
      Vector[0, 4, 0],
      Vector[4, 4, 0],
      Vector[0, 4, 0],
      Vector[4, 8, 0],
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

  it "calculates spline points properly (degree 3)" do
    spline = Spline.new CONTROL_POINTS, 3
    spline.get_precise_points(4).should eq [
      Vector[0, 0, 0],
      Vector[1.5, 2, 0],
      Vector[2, 4, 0],
      Vector[1.5, 6, 0],
      Vector[0, 8, 0],
    ]
  end

  it "calculates spline points properly (degree 4)" do
    spline = Spline.new COTROL_POINTS_EXT, 4
    spline.get_precise_points(4).should eq [
      Vector[0, 0, 0],
      Vector[1.75, 0.625, 0.0],
      Vector[2.0, 2.0, 0.0],
      Vector[2.25, 3.375, 0.0],
      Vector[4.0, 4.0, 0.0],
      Vector[2.25, 4.625, 0.0],
      Vector[2.0, 6.0, 0.0],
      Vector[1.75, 7.375, 0.0],
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