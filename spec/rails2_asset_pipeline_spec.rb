require 'spec_helper'

describe Rails2AssetPipeline do
  it "has a VERSION" do
    Rails2AssetPipeline::VERSION.should =~ /^[\.\da-z]+$/
  end
end
