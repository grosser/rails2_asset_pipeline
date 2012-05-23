require 'yaml'

module Rails2AssetPipeline
  module JammitConverter
    def self.convert
      move_to_app
      cleanup_scss
      convert_javascript_packs
      convert_stylesheet_packs
    end

    private

    def self.jammit
      @jammit ||= YAML.load_file("config/assets.yml")
    end

    def self.cleanup_scss
      stylesheets = Dir["app/assets/stylesheets/**/*"].select{|f| File.file?(f) and f =~ /\.s?css$/ }

      # cleanup import of .scss
      stylesheets.each do |file|
        content = File.read(file)
        rex = /^(@import ['"].*).scss(['"]);/
        if content =~ rex
          File.open(file, 'w'){|f| f.write content.gsub(rex, "\\1.css\\2;") }
        end
      end

      # cleanup .scss -> .css.scss
      stylesheets.each do |file|
        sh "mv #{file} #{file.sub(".scss", ".css.scss")}" if file =~ /\.scss$/ and not file =~ /\.css\.scss$/
      end
    end

    def self.convert_javascript_packs
      # convert javascript packs
      jammit["javascripts"].each do |pack, assets|
        File.open("app/assets/javascripts/#{pack}.js", "w") do |f|
          assets.each do |file|
            fuzzy = /[\/\*]*\*(.js)?$/
            f.puts "//= #{file =~ fuzzy ? "require_tree" : "require"} #{file.sub("public/javascripts/", "").sub(".js","").sub(fuzzy,"")}"
          end
        end
      end
    end

    def self.convert_stylesheet_packs
      jammit["stylesheets"].each do |pack, assets|
        File.open("app/assets/stylesheets/#{pack}.css", "w") do |f|
          f.puts "/*"
          assets.each do |file|
            f.puts " *= require #{file.sub("public/stylesheets/", "").sub(/.s?css$/,"")}"
          end
          f.puts " */"
        end
      end
    end

    # TODO only move .js/.css/.scss, no images
    def self.move_to_app
      sh "mkdir app/assets" unless File.exist?("app/assets")
      folders = ["javascripts", "stylesheets"]
      folders.each do |folder|
        target = "app/assets/#{folder}"
        raise "Remove #{target} before proceeding, I'm not merging!" if File.exist?(target)
      end
      folders.each{|f| sh "mv public/#{f} app/assets/#{f}" }
    end
  end
end
