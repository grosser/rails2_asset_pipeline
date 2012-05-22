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
end
