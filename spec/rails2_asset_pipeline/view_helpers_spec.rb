require 'spec_helper'

describe Rails2AssetPipeline::ViewHelpers do
  include Rails2AssetPipeline::ViewHelpers

  describe "#pipeline_path" do
    let(:env){ {} }

    before do
      Rails2AssetPipeline.stub(:env).and_return env
    end

    it "returns a path with query on development" do
      Rails.env = "development"
      env["xxx.js"] = mock(:mtime => Time.at(123456))
      pipeline_path("xxx.js").should == "/assets/xxx.js?123456"
    end

    it "returns a path with md5 on production" do
      Rails.env = "production"
      env["xxx.js"] = mock(:digest => "abc")
      pipeline_path("xxx.js").should == "/assets/xxx-abc.js"
    end

    it "returns a path with md5 on production and complicated file" do
      Rails.env = "production"
      env["xxx.yy.js"] = mock(:digest => "abc")
      pipeline_path("xxx.yy.js").should == "/assets/xxx-abc.yy.js"
    end

    it "silently fails with unfound assets" do
      pipeline_path("xxx.js").should == "/assets/NOT_FOUND"
    end
  end
end
