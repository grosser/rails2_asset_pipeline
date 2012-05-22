require 'spec_helper'

describe Rails2AssetPipeline do
  it "has a VERSION" do
    Rails2AssetPipeline::VERSION.should =~ /^[\.\da-z]+$/
  end

  describe ".env" do
    before do
      Rails2AssetPipeline.instance_variable_set :@env, nil
    end

    it "sets itself" do
      Rails2AssetPipeline.env.should_not == nil
    end

    it "stays the same" do
      Rails2AssetPipeline.env.object_id.should == Rails2AssetPipeline.env.object_id
    end
  end

  describe ".setup" do
    it "yields the sprocket env" do
      result = nil
      Rails2AssetPipeline.setup{|x| result = x }
      result.class.should == Sprockets::Environment
    end

    it "does not recreate the sprockets env" do
      a,b = nil
      Rails2AssetPipeline.setup{|x| a = x }
      Rails2AssetPipeline.setup{|x| b = x }
      a.object_id.should == b.object_id
    end
  end

  describe ".config_ru" do
    def map(*args)
      @mapped = args
    end

    it "sets up a route for development" do
      Rails.env = "development"
      instance_exec(&Rails2AssetPipeline.config_ru)
      @mapped.should == ["/assets"]
    end

    it "does not set up a route for production" do
      Rails.env = "production"
      instance_exec(&Rails2AssetPipeline.config_ru)
      @mapped.should == nil
    end
  end
end
