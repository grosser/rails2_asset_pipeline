$LOAD_PATH.unshift 'lib'
require 'rails2_asset_pipeline'
require 'rails2_asset_pipeline/view_helpers'

RSpec.configure do |config|
  config.before do
    # cleanup
    Rails2AssetPipeline.dynamic_assets_available = false
    Rails.env = "development"
  end
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
