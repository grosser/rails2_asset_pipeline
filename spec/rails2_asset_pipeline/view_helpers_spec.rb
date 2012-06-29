require 'spec_helper'

describe Rails2AssetPipeline::ViewHelpers do
  module FakeSuper
    def compute_public_path(*args)
      @compute_public_path = args
      :super
    end

    def rails_asset_id(*args)
      @rails_asset_id = args
      :super
    end
  end

  include FakeSuper
  include Rails2AssetPipeline::ViewHelpers

  let(:env){
    env = {}
    env.stub(:logger).and_return mock()
    env
  }

  before do
    Rails2AssetPipeline.stub(:env).and_return env
    Rails2AssetPipeline.dynamic_assets_available = true
    env["xxx.js"] = mock(:digest => "abc", :mtime => Time.at(123456))

  end

  describe "#asset_path" do
    let(:manifest){ "#{Rails.root}/public/assets/manifest.json" }

    before do
      write manifest, <<-JSON
{
  "assets": {"xxx.js": "xxx-manifest.js"},
  "files": {
    "xxx-manifest.js": {
      "logical_path": "xxx.js",
      "mtime": "2011-12-13T21:47:08-06:00",
      "digest": "manifest"
    }
  }
}
      JSON
    end

    after do
      run "rm -rf public"
    end

    it "is also static" do
      Rails2AssetPipeline::ViewHelpers.asset_path("xxx.js").should_not == nil
    end

    it "silently fails with unfound assets" do
      asset_path("yyy.js").should == "/assets/DID_NOT_FIND_yyy.js_IN_ASSETS"
    end

    context "development" do
      it "returns a path with query" do
        asset_path("xxx.js").should == "/assets/xxx.js?123456"
      end

      it "does not care if manifest is missing" do
        run "rm #{manifest}"
        asset_path("xxx.js").should == "/assets/xxx.js?123456"
      end

      it "is digested when dynamic loader is not available" do
        Rails2AssetPipeline.dynamic_assets_available = false
        asset_path("xxx.js").should == "/assets/xxx-manifest.js"
      end
    end

    context "production" do
      before do
        Rails.env = "production"
      end

      it "returns a path with digest" do
        asset_path("xxx.js").should == "/assets/xxx-manifest.js"
      end

      it "fails if file is missing from the manifest" do
        env["yyy.js"] = env["xxx.js"]
        asset_path("yyy.js").should == "/assets/DID_NOT_FIND_yyy.js_IN_MANIFEST"
      end
    end

    context "with no way of resolving assets" do
      before do
        Rails.env = "production"
        run "rm #{manifest}"
      end

      after do
        run "rm -f config.ru.example"
      end

      it "fails" do
        expect{ asset_path("yyy.js") }.to raise_error
      end

      it "does not recheck the file all the time on success" do
        write manifest, "{}"
        asset_path("yyy.js")
        run "rm #{manifest}"
        asset_path("yyy.js")
      end

      it "does recheck the file all the time on failure" do
        expect{ asset_path("yyy.js") }.to raise_error /No dynamic assets available/
        write manifest, "FooBar"
        expect{ asset_path("yyy.js") }.to raise_error /FooBar/ # unhelpful but fast
      end

      it "tells me to copy config.ru.example if it is helpful" do
        write "config.ru.example", "Rails2AssetPipeline.config_ru"
        expect{
          asset_path("yyy.js")
        }.to raise_error(/cp config.ru.example config.ru/)
      end
    end
  end

  describe "#rails_asset_id" do
    it "does not return ids for assets" do
      rails_asset_id("/assets/xxx-abc.js").should == nil
      @rails_asset_id.should == nil
    end

    it "does not return ids non-assets" do
      rails_asset_id("/javascripts/xxx.js").should == :super
      @rails_asset_id.should == ["/javascripts/xxx.js"]
    end
  end

  describe "#compute_public_path" do
    it "does nothing for symbols" do
      compute_public_path(:xxx, "a", "b").should == :super
      @compute_public_path.should == [:xxx, "a", "b"]
    end

    it "does nothing for paths starting with /" do
      compute_public_path("/xxx", "a", "b").should == :super
      @compute_public_path.should == ["/xxx", "a", "b"]
    end

    it "does nothing for urls" do
      compute_public_path("http://xxx", "a", "b").should == :super
      @compute_public_path.should == ["http://xxx", "a", "b"]
    end

    it "does nothing for ignored folders" do
      Rails2AssetPipeline::ViewHelpers.ignored_folders = ["a"]
      compute_public_path("xxx", "a", "b").should == :super
      @compute_public_path.should == ["xxx", "a", "b"]
    end

    it "converts relative, nested paths without extension" do
      env["xxx/yyy.js"] = env["xxx.js"]
      compute_public_path("xxx/yyy", "a", "js").should == :super
      @compute_public_path.should == ["/assets/xxx/yyy.js?123456", "a", "js"]
    end

    it "converts relative paths with extension" do
      compute_public_path("xxx.js", "a", "b").should == :super
      @compute_public_path.should == ["/assets/xxx.js?123456", "a", "b"]
    end

    it "converts relative paths with ." do
      env["xxxv1.2/xxx.js"] = env["xxx.js"]
      compute_public_path("xxxv1.2/xxx", "a", "js").should == :super
      @compute_public_path.should == ["/assets/xxxv1.2/xxx.js?123456", "a", "js"]
    end

    it "converts relative paths with extension and non-word characters" do
      env["xx_-x.js"] = env["xxx.js"]
      compute_public_path("xx_-x.js", "a", "b").should == :super
      @compute_public_path.should == ["/assets/xx_-x.js?123456", "a", "b"]
    end

    it "converts relative paths without extension" do
      compute_public_path("xxx", "a", "js").should == :super
      @compute_public_path.should == ["/assets/xxx.js?123456", "a", "js"]
    end

    it "converts relative paths without extension and . filenames" do
      env["xx.x.js"] = env["xxx.js"]
      compute_public_path("xx.x", "a", "js").should == :super
      @compute_public_path.should == ["/assets/xx.x.js?123456", "a", "js"]
    end
  end
end
