module Raytracer
  RAYTRACER_EXE = "trinity.exe".freeze
  RAYTRACER_DIR = "../../bin".freeze

  class << self
    def start_raytracer
      pid = spawn RAYTRACER_EXE, :chdir => RAYTRACER_DIR
    end
  end
end