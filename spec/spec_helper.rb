$LOAD_PATH.unshift 'lib'
require 'rails2_asset_pipeline'
require 'rails2_asset_pipeline/view_helpers'

RSpec.configure do |config|
  config.before do
    # cleanup
    Rails2AssetPipeline.dynamic_assets_available = false
    Rails.env = "development"
    Rails2AssetPipeline::ViewHelpers.ignored_folders = nil
    Rails2AssetPipeline.class_eval{ @manifest_exists = nil }
  end
end

def run(cmd)
  result = `#{cmd} 2>&1`
  raise "FAILED #{cmd} --> #{result}" unless $?.success?
  result
end

def write(file, content)
  folder = File.dirname(file)
  run "mkdir -p #{folder}" unless File.exist?(folder)
  File.open(file, 'w'){|f| f.write content }
end

module Rails
  def self.env
    @env || "test"
  end

  def self.env=(x)
    @env=x
  end

  def self.root
    Pathname.new(File.expand_path("../fake_rails", __FILE__))
  end
end
