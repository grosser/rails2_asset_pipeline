require 'spec_helper'

describe "Rails2AssetPipeline Tasks" do
  def run(cmd)
    result = `#{cmd} 2>&1`
    raise "FAILED #{cmd} --> #{result}" unless $?.success?
    result
  end

  def write(file, content)
    File.open(file, 'w'){|f| f.write content }
  end

  def cleanup
    run "rm -rf public/assets"
    write "app/assets/javascripts/application.js", "alert(1)"
  end

  around do |example|
    Dir.chdir File.expand_path("../../fake_rails", __FILE__) do
      begin
        cleanup
        example.call
      ensure
        cleanup
      end
    end
  end

  describe "assets:precompile" do
    it "compiles" do
      run "rake assets:precompile"
      run("ls public/assets").should == "application-84582092b2aab64d132618a3d4ac2288.js\nmanifest.json\n"
    end
  end

  describe "assets:clean" do
    it "removes everything" do
      run "rake assets:precompile"
      run "rake assets:clean"
      run("ls public").should == ""
    end
  end

  describe "assets:remove_old" do
    it "removes old" do
      4.times do |i|
        write "app/assets/javascripts/application.js", "#{i}"
        run "rake assets:precompile"
      end
      run "rake assets:remove_old" # keeps current + 2 older ones = 3
      run("ls public/assets").scan(/application-/).size.should == 3
    end
  end
end
