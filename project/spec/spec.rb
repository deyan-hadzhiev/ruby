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

  it "generate rotational matrices (x, 2 * PI)" do
    Transformations.get_rotational_matrix(:x, 2 * Math::PI).should eq Matrix.identity(3)
  end

  it "generate rotational matrices (y, PI / 2)" do
    Transformations.get_rotational_matrix(:y, Math::PI).should eq Matrix[[-1.0, 0, 0], [0, 1, 0], [0, 0, -1.0]]
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

  VECTOR_BIG_ARRAY = [
      Vector[0, 0, 0],
      Vector[50, 50, 0],
      Vector[100, 100, 0],
      Vector[42, 42, 0],
      Vector[73, 1729, 0],
    ].freeze

  it "creates vector polygons" do
    poly = Polygon.new VECTOR_ARRAY
    poly.points.should eq VECTOR_ARRAY
  end

  it "retrieves exact point" do
    poly = Polygon.new VECTOR_ARRAY
    poly.get_point(2).should eq VECTOR_ARRAY[2]
  end

  it "evaluates properly include? (true)" do
    poly = Polygon.new VECTOR_BIG_ARRAY
    poly.include?(Vector[43, 45, 0], 5).should eq true
  end

  it "evaluates properly include? (false)" do
    poly = Polygon.new VECTOR_BIG_ARRAY
    poly.include?(Vector[100, 1729, 0], 10).should eq false
  end

  it "finds a point by a given vertex and search radius" do
    poly = Polygon.new VECTOR_BIG_ARRAY
    poly.find_index(Vector[51, 52, 0], 5).should eq 1
  end

  it "removes a point" do
    poly = Polygon.new VECTOR_ARRAY
    poly.remove_point(2)
    poly.points.should eq [
      Vector[0, 0, 0],
      Vector[1.5, 2, 0],
      Vector[1.5, 6, 0],
      Vector[0, 8, 0],
    ]
  end

  it "adds a new point with :closest" do
    poly = Polygon.new VECTOR_ARRAY
    poly.add_point(Vector[1, 1, 0], :closest)
    poly.add_point(Vector[1, 7, 0], :closest)
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
    poly.add_point(Vector[1, 1, 1], :fixed, 1)
    poly.add_point(Vector[8, 9, 10], :fixed, 5)
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

describe "Revolver" do
  it "produces properly rotated points 1" do
    revolver = Revolver.new [Vector[1.0, 1.0, 1.0], Vector[1.0, 0.0, 0.0], Vector[-1.0, -1.0, 3.0]]
    revolver.rotate_points(:y, Math::PI / 2).should eq [Vector[1.0, 1.0, -1.0], Vector[0, 0, -1.0], Vector[3.0, -1.0, 1.0]]
  end

  it "produces properly rotated points 2" do
    revolver = Revolver.new [
      Vector[1.4142135623730950488016887242097, 0.0, 0.0],
      Vector[0.0, 2.8284271247461900976033774484194, 0.0],
      Vector[1.4142135623730950488016887242097, 1.4142135623730950488016887242097, 0.0],
    ]
    revolver.rotate_points(:z, Math::PI / 4).should eq [Vector[1.0, 1.0, 0.0], Vector[-2.0, 2.0, 0.0], Vector[0.0, 2.0, 0.0]]
  end
end

describe "Mesh" do
  it "creates simple mesh (1 triangle) (separate triangulation)" do
    mesh = Mesh.new [Vector[0.0, 0.0, 0.0], Vector[1.0, 0.0, 0.0], Vector[0.0, 1.0, 0.0]]
    mesh.add_triangle([0, 1, 2])
    mesh.normals.should eq [Vector[0.0, 0.0, 1.0]]
  end

  it "creates simple mesh (1 triangle) (integrated triangulation)" do
    mesh = Mesh.new [Vector[1.0, 1.0, 0.0], Vector[3.0, 1.0, 0.0], Vector[0.0, 5.0, 0.0]], [[0, 1, 2], [0, 2, 1]]
    mesh.normals.should eq [Vector[0.0, 0.0, 1.0], Vector[0.0, 0.0, -1.0]]
  end

  VERTICES = [
    Vector[0,0,0],
    Vector[1.500000, 0.000000, -2.000000],
    Vector[2.000000, 0.000000, -4.000000],
    Vector[1.500000, 0.000000, -6.000000],
    Vector[1.060660, 1.060660, -2.000000],
    Vector[1.414213, 1.414214, -4.000000],
    Vector[1.060660, 1.060660, -6.000000],
    Vector[-0.000001, 1.500000, -2.000000],
    Vector[-0.000001, 2.000000, -4.000000],
    Vector[-0.000001, 1.500000, -6.000000],
    Vector[-1.060661, 1.060659, -2.000000],
    Vector[-1.414215, 1.414212, -4.000000],
    Vector[-1.060661, 1.060659, -6.000000],
    Vector[-1.500000, -0.000002, -2.000000],
    Vector[-2.000000, -0.000003, -4.000000],
    Vector[-1.500000, -0.000002, -6.000000],
    Vector[-1.060658, -1.060662, -2.000000],
    Vector[-1.414211, -1.414216, -4.000000],
    Vector[-1.060658, -1.060662, -6.000000],
    Vector[0.000003, -1.500000, -2.000000],
    Vector[0.000004, -2.000000, -4.000000],
    Vector[0.000003, -1.500000, -6.000000],
    Vector[0.000000, 0.000000, -8.000000],
    Vector[1.060663, -1.060658, -2.000000],
    Vector[1.414217, -1.414210, -4.000000],
    Vector[1.060663, -1.060658, -6.000000],
    Vector[0.000000, 0.000000, 0.000000],
  ].freeze

  TRIANGLES = [
    [ 2, 5, 4],
    [ 3, 6, 5],
    [ 5, 8, 7],
    [ 6, 9, 8],
    [ 8, 11, 10],
    [ 9, 12, 8],
    [ 11, 14, 13],
    [ 12, 15, 14],
    [ 14, 17, 16],
    [ 15, 18, 17],
    [ 17, 20, 19],
    [ 18, 21, 20],
    [ 20, 24, 23],
    [ 21, 25, 24],
    [ 22, 6, 3],
    [ 1, 4, 26],
    [ 4, 7, 26],
    [ 22, 9, 6],
    [ 22, 12, 9],
    [ 7, 10, 26],
    [ 22, 15, 12],
    [ 10, 13, 26],
    [ 22, 18, 15],
    [ 13, 16, 26],
    [ 22, 21, 18],
    [ 16, 19, 26],
    [ 22, 25, 21],
    [ 19, 23, 26],
    [ 25, 3, 2],
    [ 22, 3, 25],
    [ 23, 1, 26],
    [ 24, 2, 1],
    [ 1, 2, 4],
    [ 2, 3, 5],
    [ 4, 5, 7],
    [ 5, 6, 8],
    [ 7, 8, 10],
    [ 10, 11, 13],
    [ 11, 12, 14],
    [ 13, 14, 16],
    [ 14, 15, 17],
    [ 16, 17, 19],
    [ 17, 18, 20],
    [ 19, 20, 23],
    [ 20, 21, 24],
    [ 24, 25, 2],
    [ 23, 24, 1],
    [ 12, 11, 8],
  ].freeze

  NORMALS = [
    Vector[0.9001804137400524, 0.37286717853418516, 0.22504508412925603],
    Vector[0.9001804272623974, 0.37286714773203644, -0.22504508107457744],
    Vector[0.3728666288863468, 0.9001806234766213, 0.22504515586915533],
    Vector[0.3728668429046424, 0.9001805400420648, -0.2250451350105162],
    Vector[-0.3728677171196428, 0.9001801772973133, 0.22504513754125754],
    Vector[-0.3728678762756316, 0.9001801371838993, -0.22504503429597483],
    Vector[-0.9001809633870518, 0.3728658695019386, 0.2250450544138282],
    Vector[-0.9001808626729655, 0.3728661278446911, -0.22504502923517747],
    Vector[-0.9001798429159935, -0.37286847879486107, 0.22504521307715827],
    Vector[-0.9001797967477364, -0.37286858395974576, -0.22504522350642822],
    Vector[-0.37286532147348683, -0.9001811770339017, 0.22504510782581474],
    Vector[-0.3728653971400751, -0.9001811475355859, -0.2250451004511979],
    Vector[0.3728690551477894, -0.9001796976522657, 0.22504483919403762],
    Vector[0.3728686217277895, -0.9001798879273943, -0.2250447962114265],
    Vector[0.7593925002869187, 0.3145508467143618, -0.5695443752151891],
    Vector[0.7593925002869187, 0.3145508467143618, 0.5695443752151891],
    Vector[0.3145506076715482, 0.7593926391485225, 0.5695443220860881],
    Vector[0.3145506076715482, 0.7593926391485225, -0.5695443220860881],
    Vector[-0.31455146366136555, 0.7593922612436901, -0.5695443532084994],
    Vector[-0.31455146366136555, 0.7593922612436901, 0.5695443532084994],
    Vector[-0.7593928781908302, 0.3145499907241626, -0.5695443440931319],
    Vector[-0.7593928781908302, 0.3145499907241626, 0.5695443440931319],
    Vector[-0.7593920221999693, -0.31455208060771483, -0.5695443312020576],
    Vector[-0.7593920221999693, -0.31455208060771483, 0.5695443312020576],
    Vector[-0.3145493737761228, -0.759393117232646, -0.5695443661004238],
    Vector[-0.3145493737761228, -0.759393117232646, 0.5695443661004238],
    Vector[0.31455205243149914, -0.7593919541769144, -0.5695444374607644],
    Vector[0.31455205243149914, -0.7593919541769144, 0.5695444374607644],
    Vector[0.9001810406500982, -0.37286555879095074, -0.22504526016252455],
    Vector[0.7593928716696074, -0.31454944577866795, -0.5695446537522056],
    Vector[0.7593928716696074, -0.31454944577866795, 0.5695446537522056],
    Vector[0.9001809104372741, -0.3728658928014069, 0.22504522760931853],
    Vector[0.9001804220477507, 0.37286714557205786, 0.22504510551193768],
    Vector[0.9001804098290693, 0.37286717691420185, -0.22504510245726733],
    Vector[0.3728668281553448, 0.9001805044340967, 0.2250453018797497],
    Vector[0.3728666178243737, 0.9001805967706276, -0.2250452810211517],
    Vector[-0.3728678762756316, 0.9001801371838993, 0.22504503429597483],
    Vector[-0.9001808196903779, 0.3728661100407678, 0.22504523066402768],
    Vector[-0.9001809311501109, 0.37286585614900686, -0.22504520548544804],
    Vector[-0.90017981455162, -0.37286859133439343, 0.22504514007220067],
    Vector[-0.9001798562689106, -0.3728684843258468, -0.2250451505014698],
    Vector[-0.3728653919254568, -0.9001811349463215, 0.22504515944811637],
    Vector[-0.37286531756252467, -0.900181167591955, -0.22504515207349463],
    Vector[0.37286859133439343, -0.90017981455162, 0.22504514007220067],
    Vector[0.37286903235271485, -0.900179642620444, -0.22504509708962717],
    Vector[0.9001809521161739, -0.37286591006531467, -0.225045032289947],
    Vector[0.9001810962219554, -0.3728655818094666, 0.2250449997367789],
    Vector[-0.3728677171196428, 0.9001801772973133, -0.22504513754125757]
  ].freeze

  it "creates complicated mesh" do
    mesh = Mesh.new VERTICES, TRIANGLES
    mesh.normals.should eq NORMALS
  end
end

describe "PolygonIndiceCalculator" do
  it "calculates triangle indices" do
    indices = PolygonIndiceCalculator.get_indices(5)
    indices.should eq [[0, 1, 5], [1, 6, 5], [1, 2, 6], [2, 7, 6], [2, 3, 7], [3, 8, 7], [3, 4, 8], [4, 9, 8]]
  end

  it "calculates wrapped triangle indices" do
    indices = PolygonIndiceCalculator.get_indices(5, 2)
    indices = PolygonIndiceCalculator.wrap_indices(indices, 15)
    indices.should eq [[10, 11, 0], [11, 1, 0], [11, 12, 1], [12, 2, 1], [12, 13, 2], [13, 3, 2], [13, 14, 3], [14, 4, 3]]
  end

  it "calculates end (top and bottom) indices" do
    indices = PolygonIndiceCalculator.get_end_indices(8, 9, 2, 4)
    indices.should eq [[8, 0, 2], [8, 2, 4], [8, 4, 6], [8, 6, 0], [9, 3, 1], [9, 5, 3], [9, 7, 5], [9, 1, 7]]
  end
end

describe "MeshGenerator" do
  SPLINE_VERTICES = [
    Vector[0.0, 0.0, 0.0],
    Vector[4.0, 4.0, 0.0],
    Vector[0.0, 8.0, 0.0],
  ]

  it "generates vertices in mesh from spline" do
    mesh_generator = MeshGenerator.new polygon: SPLINE_VERTICES, degree: 3, precision: 4, rotations: 8
    mesh = mesh_generator.get_mesh
    mesh.vertices.should eq [
      Vector[1.5, 6.0, 0.0],
      Vector[2.0, 4.0, 0.0],
      Vector[1.5, 2.0, 0.0],
      Vector[1.0606601717798214, 6.0, -1.0606601717798212],
      Vector[1.4142135623730951, 4.0, -1.414213562373095],
      Vector[1.0606601717798214, 2.0, -1.0606601717798212],
      Vector[9.18454765366783e-17, 6.0, -1.5],
      Vector[1.2246063538223773e-16, 4.0, -2.0],
      Vector[9.18454765366783e-17, 2.0, -1.5],
      Vector[-1.0606601717798212, 6.0, -1.0606601717798214],
      Vector[-1.414213562373095, 4.0, -1.4142135623730951],
      Vector[-1.0606601717798212, 2.0, -1.0606601717798214],
      Vector[-1.5, 6.0, -1.836909530733566e-16],
      Vector[-2.0, 4.0, -2.4492127076447545e-16],
      Vector[-1.5, 2.0, -1.836909530733566e-16],
      Vector[-1.0606601717798214, 6.0, 1.0606601717798212],
      Vector[-1.4142135623730954, 4.0, 1.414213562373095],
      Vector[-1.0606601717798214, 2.0, 1.0606601717798212],
      Vector[-2.755364296100349e-16, 6.0, 1.5],
      Vector[-3.673819061467132e-16, 4.0, 2.0],
      Vector[-2.755364296100349e-16, 2.0, 1.5],
      Vector[1.060660171779821, 6.0, 1.0606601717798214],
      Vector[1.4142135623730947, 4.0, 1.4142135623730954],
      Vector[1.060660171779821, 2.0, 1.0606601717798214],
      Vector[0.0, 8.0, 0.0],
      Vector[0.0, 0.0, 0.0]
    ]
  end

  it "generates triangle indices in mesh from spline" do
    mesh_generator = MeshGenerator.new polygon: SPLINE_VERTICES, degree: 3, precision: 4, rotations: 8
    mesh = mesh_generator.get_mesh
    mesh.triangles.should eq [
      [0, 1, 3],
      [1, 4, 3],
      [1, 2, 4],
      [2, 5, 4],
      [3, 4, 6],
      [4, 7, 6],
      [4, 5, 7],
      [5, 8, 7],
      [6, 7, 9],
      [7, 10, 9],
      [7, 8, 10],
      [8, 11, 10],
      [9, 10, 12],
      [10, 13, 12],
      [10, 11, 13],
      [11, 14, 13],
      [12, 13, 15],
      [13, 16, 15],
      [13, 14, 16],
      [14, 17, 16],
      [15, 16, 18],
      [16, 19, 18],
      [16, 17, 19],
      [17, 20, 19],
      [18, 19, 21],
      [19, 22, 21],
      [19, 20, 22],
      [20, 23, 22],
      [21, 22, 0],
      [22, 1, 0],
      [22, 23, 1],
      [23, 2, 1],
      [24, 0, 3],
      [24, 3, 6],
      [24, 6, 9],
      [24, 9, 12],
      [24, 12, 15],
      [24, 15, 18],
      [24, 18, 21],
      [24, 21, 0],
      [25, 5, 2],
      [25, 8, 5],
      [25, 11, 8],
      [25, 14, 11],
      [25, 17, 14],
      [25, 20, 17],
      [25, 23, 20],
      [25, 2, 23],
    ]
  end

  it "generates triangle normals from spline" do
    mesh_generator = MeshGenerator.new polygon: SPLINE_VERTICES, degree: 3, precision: 4, rotations: 8
    mesh = mesh_generator.get_mesh
    mesh.normals.should eq [
      Vector[0.9001804912506243, 0.22504512281265607, -0.3728669680596837],
      Vector[0.9001804912506243, 0.22504512281265607, -0.3728669680596838],
      Vector[0.9001804912506243, -0.22504512281265607, -0.3728669680596838],
      Vector[0.9001804912506243, -0.22504512281265607, -0.3728669680596837],
      Vector[0.37286696805968383, 0.22504512281265607, -0.9001804912506243],
      Vector[0.3728669680596839, 0.2250451228126561, -0.9001804912506243],
      Vector[0.3728669680596839, -0.22504512281265607, -0.9001804912506243],
      Vector[0.37286696805968383, -0.22504512281265612, -0.9001804912506243],
      Vector[-0.3728669680596837, 0.22504512281265607, -0.9001804912506243],
      Vector[-0.3728669680596837, 0.22504512281265607, -0.9001804912506243],
      Vector[-0.3728669680596837, -0.22504512281265607, -0.9001804912506243],
      Vector[-0.3728669680596837, -0.22504512281265607, -0.9001804912506243],
      Vector[-0.9001804912506243, 0.22504512281265607, -0.37286696805968395],
      Vector[-0.9001804912506243, 0.22504512281265607, -0.3728669680596839],
      Vector[-0.9001804912506243, -0.22504512281265607, -0.3728669680596839],
      Vector[-0.9001804912506243, -0.22504512281265607, -0.37286696805968395],
      Vector[-0.9001804912506243, 0.22504512281265607, 0.37286696805968367],
      Vector[-0.9001804912506244, 0.22504512281265618, 0.3728669680596836],
      Vector[-0.9001804912506244, -0.2250451228126561, 0.3728669680596836],
      Vector[-0.9001804912506243, -0.22504512281265612, 0.37286696805968367],
      Vector[-0.37286696805968395, 0.22504512281265612, 0.9001804912506243],
      Vector[-0.3728669680596839, 0.2250451228126561, 0.9001804912506243],
      Vector[-0.3728669680596839, -0.2250451228126561, 0.9001804912506243],
      Vector[-0.37286696805968395, -0.22504512281265612, 0.9001804912506243],
      Vector[0.3728669680596837, 0.22504512281265607, 0.9001804912506243],
      Vector[0.3728669680596836, 0.22504512281265618, 0.9001804912506244],
      Vector[0.3728669680596836, -0.2250451228126561, 0.9001804912506244],
      Vector[0.3728669680596837, -0.22504512281265618, 0.9001804912506243],
      Vector[0.9001804912506243, 0.22504512281265612, 0.37286696805968406],
      Vector[0.9001804912506243, 0.22504512281265607, 0.37286696805968395],
      Vector[0.9001804912506243, -0.22504512281265615, 0.37286696805968395],
      Vector[0.9001804912506243, -0.22504512281265607, 0.37286696805968406],
      Vector[0.7593925418334084, 0.5695444063750564, -0.3145506899923757],
      Vector[0.3145506899923758, 0.5695444063750563, -0.7593925418334085],
      Vector[-0.3145506899923757, 0.5695444063750564, -0.7593925418334084],
      Vector[-0.7593925418334084, 0.5695444063750564, -0.31455068999237584],
      Vector[-0.7593925418334085, 0.5695444063750563, 0.3145506899923756],
      Vector[-0.31455068999237584, 0.5695444063750564, 0.7593925418334084],
      Vector[0.3145506899923757, 0.5695444063750563, 0.7593925418334084],
      Vector[0.7593925418334084, 0.5695444063750563, 0.3145506899923759],
      Vector[0.7593925418334084, -0.5695444063750564, -0.3145506899923757],
      Vector[0.3145506899923758, -0.5695444063750563, -0.7593925418334085],
      Vector[-0.3145506899923757, -0.5695444063750564, -0.7593925418334084],
      Vector[-0.7593925418334084, -0.5695444063750564, -0.31455068999237584],
      Vector[-0.7593925418334085, -0.5695444063750563, 0.3145506899923756],
      Vector[-0.31455068999237584, -0.5695444063750564, 0.7593925418334084],
      Vector[0.3145506899923757, -0.5695444063750563, 0.7593925418334084],
      Vector[0.7593925418334084, -0.5695444063750563, 0.3145506899923759],
    ]
  end
end

describe "MeshExporter" do
  it "exports proper .obj files" do
    mesh = Mesh.new [Vector[0.0, 0.0, 0.0], Vector[1.0, 0.0, 0.0], Vector[0.0, 1.0, 0.0]], [[0, 1, 2], [0, 2, 1]]
    mesh_exporter = MeshExporter.new mesh
    mesh_exporter.export("C:/test.obj")

    file_input = []
    File.open("C:/test.obj", "r").each_line do |line|
      file_input << line.strip
    end

    file_input.should eq [
      "v 0.000000 0.000000 0.000000",
      "v 1.000000 0.000000 0.000000",
      "v 0.000000 1.000000 0.000000",
      "vn 0.000000 0.000000 1.000000",
      "vn 0.000000 0.000000 -1.000000",
      "f 1//1 2//1 3//1",
      "f 1//2 3//2 2//2",
    ]
  end
end