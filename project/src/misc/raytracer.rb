require 'FileUtils'

module Raytracer
  RAYTRACER_EXE = "trinity.exe".freeze
  RAYTRACER_DIR = "../../bin".freeze
  RAYTRACER_DATA_DIR = "../../bin/data".freeze
  RAYTRACER_SCENE_FILE = "default.trinity".freeze

  class << self
    def start_raytracer
      pid = spawn RAYTRACER_EXE, :chdir => RAYTRACER_DIR
    end

    def copy_obj_file(filename)
      FileUtils.copy(filename, RAYTRACER_DATA_DIR)
    end

    def create_scene(filename)
      contents = ""
      File.open("../misc/" + RAYTRACER_SCENE_FILE, "r") do |file|
        contents = file.read
      end

      formatted_contents = contents % filename

      File.open(RAYTRACER_DATA_DIR + "/" + RAYTRACER_SCENE_FILE, "w") do |file|
        file.write formatted_contents
      end
    end
  end
end