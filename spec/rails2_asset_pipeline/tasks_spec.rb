require 'spec_helper'

describe "Rails2AssetPipeline Tasks" do
  def cleanup
    run "rm -rf public/assets"
    run "rm -rf public/javascripts"
    run "rm -rf public/stylesheets"
    run "rm -rf app/assets"
    run "rm -rf config/initializers"
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

  describe "assets:config" do
    it "loads the initializer" do
      write "config/initializers/rails2_asset_pipeline.rb", "puts 'Foo'"
      run("rake assets:config").should =~ /Foo/
    end
  end

  describe "assets:precompile" do
    it "compiles" do
      run "rake assets:precompile"
      run("ls public/assets").should == "application-09565e705ecd8821e8ca69c50e3e2bae.js\nmanifest.json\n"
    end

    context "with a custom prefix" do
      after do
        run "rm -rf public/static-assets"
      end

      it "compiles" do
        write "config/initializers/rails2_asset_pipeline.rb", "Rails2AssetPipeline.prefix = 'static-assets'"
        run "rake assets:precompile"
        run("ls public/static-assets").should == "application-09565e705ecd8821e8ca69c50e3e2bae.js\nmanifest.json\n"
      end
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
      run("cat app/assets/javascripts/pack.js").should == "//= require a\n//= require b\n//= require_tree ./c\n"
    end

    it "moves and combines stylesheets" do
      run "rake assets:convert_jammit"
      run("ls app/assets").should == "javascripts\nstylesheets\n"
      run("ls app/assets/stylesheets").should == "a.css\nb.css\npack.css\n"
      run("cat app/assets/stylesheets/pack.css").should == "/*\n *= require a\n *= require b\n */\n"
    end

    it "renames .scss to .css.scss" do
      write "public/stylesheets/c.scss", "C"
      run "rake assets:convert_jammit"
      run("ls app/assets/stylesheets").should include("\nc.css.scss\n")
    end

    it "does not renames .css.scss to .css.css.scss" do
      write "public/stylesheets/c.css.scss", "C"
      run "rake assets:convert_jammit"
      run("ls app/assets/stylesheets").should include("\nc.css.scss\n")
    end

    it "fixes broken inputs" do
      write "public/stylesheets/c.css.scss", "a{}\n@import \"../global/_tables.scss\";\na{}"
      run "rake assets:convert_jammit"
      run("cat app/assets/stylesheets/c.css.scss").should == "a{}\n@import \"../global/_tables\";\na{}"
    end
  end
end
