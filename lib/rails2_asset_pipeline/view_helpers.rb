module Rails2AssetPipeline
  module ViewHelpers
    class << self
      attr_accessor :ignored_folders # e.g. 'images'
    end

    # Overwrite rails helper to use pipeline path for all relative assets
    # args: source, 'javascripts', 'js'
    def compute_public_path(*args)
      source = args[0]
      ignored_folders = Rails2AssetPipeline::ViewHelpers.ignored_folders
      source_is_relative = (
        source.is_a?(String) and
        source =~ /^[a-z]+(\/|\.|$)/ and # xxx or xxx.js or xxx/yyy, not /xxx or http://
        not (ignored_folders and ignored_folders.include?(args[1]))
      )

      if source_is_relative
        source = "#{source}.#{args[2]}" unless source.include?(".")
        super(asset_path(source), *args[1..-1])
      else
        super
      end
    end

    def asset_path(asset)
      data = Rails2AssetPipeline.env[asset]
      return "/assets/NOT_FOUND" unless data
      asset = "/assets/#{asset}"

      if not Rails2AssetPipeline.dynamic_assets_available or Rails2AssetPipeline::STATIC_ENVIRONMENTS.include?(Rails.env)
        asset.sub(/(\.[\.a-z]+$)/, "-#{data.digest}\\1")
      else
        "#{asset}?#{data.mtime.to_i}"
      end
    end
    module_function :asset_path
  end
end
