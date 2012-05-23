module Rails2AssetPipeline
  module ViewHelpers
    def pipeline_path(asset)
      data = Rails2AssetPipeline.env[asset]
      return "/assets/NOT_FOUND" unless data
      asset = "/assets/#{asset}"

      if not Rails2AssetPipeline.dynamic_assets_available or Rails2AssetPipeline::STATIC_ENVIRONMENTS.include?(Rails.env)
        asset.sub(/(\.[\.a-z]+$)/, "-#{data.digest}\\1")
      else
        "#{asset}?#{data.mtime.to_i}"
      end
    end
  end
end
