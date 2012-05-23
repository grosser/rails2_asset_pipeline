require 'rails2_asset_pipeline/version'
require 'sprockets'

module Rails2AssetPipeline
  STATIC_ENVIRONMENTS = ["production", "staging"]

  class << self
    attr_accessor :dynamic_assets_available
  end

  def self.env
    @env || setup
  end

  def self.setup
    @env ||= Sprockets::Environment.new
    Dir[Rails.root.join("app", "assets", "*")].each do |folder|
      @env.append_path folder
    end
    # TODO vendor + lib
    yield @env if block_given?
    @env
  end

  def self.config_ru
    lambda do
      unless STATIC_ENVIRONMENTS.include?(Rails.env)
        Rails2AssetPipeline.dynamic_assets_available = true
        map '/assets' do
          run Rails2AssetPipeline.env
        end
      end
    end
  end
end
