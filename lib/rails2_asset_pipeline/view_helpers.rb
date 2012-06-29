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
        source =~ /^[\w\-]+(\/|\.|$)/ and # xxx or xxx.js or xxx/yyy, not /xxx or http://
        not (ignored_folders and ignored_folders.include?(args[1]))
      )

      if source_is_relative
        source = "#{source}.#{args[2]}" unless source =~ /\.#{args[2]}$/o
        super(asset_path(source), *args[1..-1])
      else
        super
      end
    end

    def rails_asset_id(file)
      if file.start_with?("/assets/")
        nil
      else
        super
      end
    end

    def asset_path(asset)
      Rails2AssetPipeline.warn_user_about_misconfiguration!

      asset_with_id = if Rails2AssetPipeline.static?
        @sprockets_manifest ||= Sprockets::Manifest.new(Rails2AssetPipeline.env, Rails2AssetPipeline.manifest)
        @sprockets_manifest.assets[asset] || "DID_NOT_FIND_#{asset}_IN_MANIFEST"
      else
        data = Rails2AssetPipeline.env[asset]
        data ? "#{asset}?#{data.mtime.to_i}" : "DID_NOT_FIND_#{asset}_IN_ASSETS"
      end

      "/assets/#{asset_with_id}"
    end
    module_function :asset_path
  end
end
