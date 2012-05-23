$LOAD_PATH.unshift 'lib'
require 'rails2_asset_pipeline'
require 'rails2_asset_pipeline/view_helpers'

RSpec.configure do |config|
  config.before do
    # cleanup
    Rails2AssetPipeline.dynamic_assets_available = false
  end
end

module Rails
  def self.env
    @env || "test"
  end

  def self.env=(x)
    @env=x
  end
end
