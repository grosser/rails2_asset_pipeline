require 'spec_helper'

describe "Rails2AssetPipeline Tasks" do
  def run(cmd)
    result = `#{cmd} 2>&1`
    raise "FAILED #{cmd} --> #{result}" unless $?.success?
    result
  end

  def write(file, content)
    folder = File.dirname(file)
    run "mkdir -p #{folder}" unless File.exist?(folder)
    File.open(file, 'w'){|f| f.write content }
  end

  def cleanup
    run "rm -rf public/assets"
    run "rm -rf public/javascripts"
    run "rm -rf public/stylesheets"
    run "rm -rf app/assets"
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
      run("ls public/assets").should == "application-ceff92e831a69f6e164737670664e886.js\nmanifest.json\n"
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

  describe "assets:convert_jammit" do
    before do
      run "rm -rf app/assets"
      write "public/javascripts/a.js", "A"
      write "public/javascripts/b.js", "B"
      write "public/stylesheets/a.css", "A"
      write "public/stylesheets/b.css", "A"
    end

    it "fails when folders already exist" do
      run "mkdir -p app/assets/javascripts"
      expect{
        puts run "rake assets:convert_jammit"
      }.to raise_error
    end

    it "moves and combines javascripts" do
      run "rake assets:convert_jammit"
      run("ls app/assets").should == "javascripts\nstylesheets\n"
      run("ls app/assets/javascripts").should == "a.js\nb.js\npack.js\n"
      run("cat app/assets/javascripts/pack.js").should == "//= require a\n//= require b\n"
    end

    it "moves and combines stylesheets" do
      run "rake assets:convert_jammit"
      run("ls app/assets").should == "javascripts\nstylesheets\n"
      run("ls app/assets/stylesheets").should == "a.css\nb.css\npack.css\n"
      run("cat app/assets/stylesheets/pack.css").should == "/*\n *= require a\n *= require b\n */\n"
    end
  end
end
