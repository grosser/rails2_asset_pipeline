# Rails 2 Asset pipeline

Familiar asset handling for those stuck on Rails 2.

 - sprockets/coffee/sass etc goodness
 - application.js?time for development
 - application-MD5.js for production  (and development without config.ru, read from public/assets/manifest.json)
 - old asset versions can stay around during deploys
 - converter for jammit asset.yml
 - no forced monkey-patching, everything is opt-in

[Example application](https://github.com/grosser/rails2_asset_pipeline_exmaple)

# Usage

```
rake assets:precompile
rake assets:clean
rake assets:remove_old      # Keeps current + 2 older versions in public/assets
rake assets:convert_jammit  # reads config/assets.yml and converts packs into `app/assets/<type>/<pack>.js` with `//= require <dependency>`
```

```Erb
With ViewHelpers included you can:
<%= stylesheet_link_tag "application" %>
<%= javascript_include_tag "application" %>
<%= image_tag "foo.jpg" %> <-- will go to public if you set Rails2AssetPipeline::ViewHelpers.ignored_folders = ["images"]
From good old public <%= javascript_include_tag "/javascripts/application.js" %>
Just a path: <%= asset_path "application.js" %>
```


# Install

    gem install rails2_asset_pipeline

    # config/environment.rb
    config.gem "rails2_asset_pipeline"

### Initializer
Here you can do additional configuration of sprockets.

```Ruby
# config/initializers/rails2_asset_pipeline.rb
# will be loaded without the rails environment when running rake assets:precompile
Rails2AssetPipeline.setup do |sprockets|
  # ... additional config ...
end
```

### Tasks

    # Rakefile
    begin
      require "rails2_asset_pipeline/tasks"
    rescue LoadError
      puts "rails2_asset_pipeline is not installed, you probably should run 'rake gems:install' or 'bundle install'."
    end

### Dynamic assets for development
Setup a config.ru so development has dynamic assets

```Ruby
# config.ru
# we need to protect against multiple includes of the Rails environment (trust me)
require './config/environment' if !defined?(Rails) || !Rails.initialized?

instance_exec(&Rails2AssetPipeline.config_ru)

map '/' do
  use Rails::Rack::LogTailer unless Rails.env.test?
  # use Rails::Rack::Debugger unless Rails.env.test?
  use Rails::Rack::Static
  run ActionController::Dispatcher.new
end
```

### View helpers
```
# app/helpers/application_helper.rb
require 'rails2_asset_pipeline/view_helpers'
module ApplicationHelper
  include Rails2AssetPipeline::ViewHelpers
  ...
end
```

### Static code
You can also use `Rails2AssetPipeline::ViewHelpers.asset_path("application.js")`

### Sass
 - add `sass` to your gems for sass parsing
 - add `sprockets-sass` to your gems for sass @import support


# Todo
 - read config from Rails 3 style config.assets
 - asset image helpers for inside css/scss
 - make output location configurable in .setup and use it for manifest location and rake tasks

Author
======
[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
License: MIT<br/>
[![Build Status](https://secure.travis-ci.org/grosser/rails2_asset_pipeline.png)](http://travis-ci.org/grosser/rails2_asset_pipeline)
