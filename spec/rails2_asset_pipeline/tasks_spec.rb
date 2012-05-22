require 'spec_helper'

describe "Rails2AssetPipeline Tasks" do
  def run(cmd)
    result = `#{cmd} 2>&1`
    raise "FAILED #{cmd} --> #{result}" unless $?.success?
    result
  end

  around do |example|
    Dir.chdir File.expand_path("../../fake_rails", __FILE__) do
      run "rm -rf public/assets"
      example.call
      run "rm -rf public/assets"
    end
  end

  describe "assets:precompile" do
    it "compiles" do
      run "rake assets:precompile"
      run("ls public/assets").should == "application-c2ee74b62870d06b4b4ad6819b9bf142.js\n\manifest.json\n"
    end
  end
end
