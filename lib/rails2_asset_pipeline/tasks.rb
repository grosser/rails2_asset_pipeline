require 'rake/sprocketstask'

namespace :assets do
  load_tasks = lambda do
    namespace :r2ap do
      Rake::SprocketsTask.new do |t|
        t.environment = Rails2AssetPipeline.env
        t.output = "./public/assets"
        t.assets = t.environment.paths.map{|p| Dir["#{p.sub(Rails.root.to_s,"")}/**/*"] }.flatten
        t.keep = 2
      end
    end
  end

  desc "Compile all the assets"
  task :precompile => :environment do
    load_tasks.call
    Rake::Task["r2ap:assets"].invoke
  end

  desc "Remove compiled assets"
  task :clean => :environment do
    load_tasks.call
    Rake::Task["r2ap:clobber"].invoke
  end

  desc "Remove old assets"
  task :remove_old => :environment do
    load_tasks.call
    Rake::Task["r2ap:clean"].invoke
  end

  desc "converts project from jammit based assets.yml"
  task :convert_jammit do
    require 'yaml'

    sh "mkdir app/assets" unless File.exist?("app/assets")
    sh "mv public/javascripts app/assets/javascripts"
    sh "mv public/stylesheets app/assets/stylesheets"

    jammit = YAML.load_file("config/assets.yml")

    jammit["javascripts"].each do |pack, assets|
      File.open("app/assets/javascripts/#{pack}.js", "w") do |f|
        assets.each do |file|
          f.puts "//= require #{file.sub("public/javascripts", "").sub(".js","")}"
        end
      end
    end

    jammit["stylesheets"].each do |pack, assets|
      File.open("app/assets/stylesheets/#{pack}.css", "w") do |f|
        f.puts "/*"
        assets.each do |file|
          f.puts "//= require #{file.sub("public/stylesheets", "").sub(".css","")}"
        end
        f.puts " */"
      end
    end
  end
end
