require 'rails2_asset_pipeline/version'
require 'sprockets'

module Rails2AssetPipeline
  STATIC_ENVIRONMENTS = ["production", "staging"]

  class << self
    attr_accessor :dynamic_assets_available, :manifest
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

  def self.static?
    not Rails2AssetPipeline.dynamic_assets_available or Rails2AssetPipeline::STATIC_ENVIRONMENTS.include?(Rails.env)
  end

  def self.with_dynamic_assets_available(value)
    old = dynamic_assets_available
    self.dynamic_assets_available = value
    yield
  ensure
    self.dynamic_assets_available = old
  end

  def self.manifest
    @manifest ||= "#{Rails.root}/public/assets/manifest.json"
  end

  def self.warn_user_about_misconfiguration!
    return unless Rails2AssetPipeline.static?
    return if @manifest_exists ||= File.exist?(manifest)

    config = "config.ru.example"
    if File.exist?(config) and File.read(config).include?("Rails2AssetPipeline.config_ru")
      raise "No dynamic assets available and no #{manifest} found, run `rake assets:precompile` for static assets or `cp #{config} config.ru` for dynamic assets"
    else
      raise "No dynamic assets available and no #{manifest} found, run `rake assets:precompile` for static assets or read https://github.com/grosser/rails2_asset_pipeline#dynamic-assets-for-development for instructions on dynamic assets"
    end
  end
end
