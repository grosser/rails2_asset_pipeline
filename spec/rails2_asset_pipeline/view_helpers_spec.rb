require 'spec_helper'

describe Rails2AssetPipeline::ViewHelpers do
  include Rails2AssetPipeline::ViewHelpers

  describe "#pipeline_path" do
    let(:env){ {} }

    before do
      Rails2AssetPipeline.stub(:env).and_return env
      Rails2AssetPipeline.dynamic_assets_available = true
      env["xxx.js"] = mock(:digest => "abc", :mtime => Time.at(123456))
    end

    it "silently fails with unfound assets" do
      pipeline_path("yyy.js").should == "/assets/NOT_FOUND"
    end

    context "development" do
      before do
        Rails.env = "development"
      end

      it "returns a path with query" do
        pipeline_path("xxx.js").should == "/assets/xxx.js?123456"
      end

      it "returns a path with digest when dynamic loader is not available" do
        Rails2AssetPipeline.dynamic_assets_available = false
        pipeline_path("xxx.js").should == "/assets/xxx-abc.js"
      end
    end

    context "production" do
      before do
        Rails.env = "production"
      end

      it "returns a path with md5" do
        pipeline_path("xxx.js").should == "/assets/xxx-abc.js"
      end

      it "returns a path with md5 on production and complicated file" do
        env["xxx.yy.js"] = env["xxx.js"]
        pipeline_path("xxx.yy.js").should == "/assets/xxx-abc.yy.js"
      end
    end
  end
end
