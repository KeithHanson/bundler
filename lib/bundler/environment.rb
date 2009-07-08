module Bundler
  class Environment
    def initialize(path)
      if !File.directory?(path)
        raise ArgumentError, "#{path} is not a directory"
      elsif !File.directory?(File.join(path, "cache"))
        raise ArgumentError, "#{path} is not a valid environment (it does not contain a cache directory)"
      end

      @path = path
      @gems = Dir[(File.join(path, "cache", "*.gem"))]
    end

    def install(bin_dir = File.join(@path, "bin"))
      @gems.each do |gem|
        installer = Gem::Installer.new(gem, :install_dir => @path,
          :ignore_dependencies => true,
          :env_shebang => true,
          :wrappers => true,
          :bin_dir => bin_dir)
        installer.install
      end
    end

    def load_paths
      index = Gem::SourceIndex.from_gems_in(File.join(@path, "specifications"))
      load_paths = []
      index.each do |name, spec|
        spec.require_paths.each do |path|
          load_paths << File.join(spec.full_gem_path, path)
        end
        load_paths << File.join(spec.full_gem_path, spec.bindir) if spec.bindir
      end
      load_paths
    end
  end
end