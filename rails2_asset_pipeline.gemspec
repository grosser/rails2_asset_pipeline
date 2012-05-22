$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
name = "rails2_asset_pipeline"
require "#{name}/version"

Gem::Specification.new name, Rails2AssetPipeline::VERSION do |s|
  s.summary = "Familiar asset handling for those stuck on Rails 2"
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "http://github.com/grosser/#{name}"
  s.files = `git ls-files`.split("\n")
  s.license = 'MIT'
end
