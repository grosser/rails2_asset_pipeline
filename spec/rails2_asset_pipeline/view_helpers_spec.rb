require 'spec_helper'

describe Rails2AssetPipeline::ViewHelpers do
  module FakeSuper
    def compute_public_path(*args)
      @compute_public_path = args
      :super
    end
  end

  include FakeSuper
  include Rails2AssetPipeline::ViewHelpers

  let(:env){ {} }

  before do
    Rails2AssetPipeline.stub(:env).and_return env
    Rails2AssetPipeline.dynamic_assets_available = true
    env["xxx.js"] = mock(:digest => "abc", :mtime => Time.at(123456))
  end

  describe "#asset" do
    it "is also static" do
      Rails2AssetPipeline::ViewHelpers.asset_path("xxx.js").should_not == nil
    end

    it "silently fails with unfound assets" do
      asset_path("yyy.js").should == "/assets/NOT_FOUND"
    end

    context "development" do
      it "returns a path with query" do
        asset_path("xxx.js").should == "/assets/xxx.js?123456"
      end

      it "returns a path with digest when dynamic loader is not available" do
        Rails2AssetPipeline.dynamic_assets_available = false
        asset_path("xxx.js").should == "/assets/xxx-abc.js"
      end
    end

    context "production" do
      before do
        Rails.env = "production"
      end

      it "returns a path with md5" do
        asset_path("xxx.js").should == "/assets/xxx-abc.js"
      end

      it "returns a path with md5 on production and complicated file" do
        env["xxx.yy.js"] = env["xxx.js"]
        asset_path("xxx.yy.js").should == "/assets/xxx-abc.yy.js"
      end
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

    it "converts relative paths with extension and non-word characters" do
      env["xx_-x.js"] = env["xxx.js"]
      compute_public_path("xx_-x.js", "a", "b").should == :super
      @compute_public_path.should == ["/assets/xx_-x.js?123456", "a", "b"]
    end

    it "converts relative paths without extension" do
      compute_public_path("xxx", "a", "js").should == :super
      @compute_public_path.should == ["/assets/xxx.js?123456", "a", "js"]
    end
  end
end
