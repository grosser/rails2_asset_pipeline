module Rails2AssetPipeline
  module ViewHelpers
    def pipeline_path(asset)
      data = Rails2AssetPipeline.env[asset]
      return "/assets/NOT_FOUND" unless data
      asset = "/assets/#{asset}"

      if Rails2AssetPipeline::STATIC_ENVIRONMENTS.include?(Rails.env) and Rails2AssetPipeline.dynamic_assets_available
        asset.sub(/(\.[\.a-z]+$)/, "-#{data.digest}\\1")
      else
        "#{asset}?#{data.mtime.to_i}"
      end
    end
  end
end
