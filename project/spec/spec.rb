require 'Matrix'

describe "Polygon tests" do
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

describe "Spline tests" do
end

describe "Polygon Resolver tests" do
end

describe "Mesh tests" do
end

describe "Mesh Exporter tests" do
end