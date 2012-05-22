$LOAD_PATH.unshift 'lib'
require 'rails2_asset_pipeline'
require 'rails2_asset_pipeline/view_helpers'

module Rails
  def self.env
    @env || "test"
  end

  def self.env=(x)
    @env=x
  end
end
