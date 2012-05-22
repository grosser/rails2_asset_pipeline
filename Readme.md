# Rails 2 Asset pipeline

Familiar asset handling for those stuck on Rails 2.

 - sprockets/coffee/sass etc goodness
 - application.js?time for development
 - application-MD5.js for production
 - old asset versions can stay around during deploys

# Usage

```
rake assets:precompile
rake assets:clean
```

```Erb
<%= stylesheet_link_tag pipeline_path("application.css") %>
<%= javascript_include_tag pipeline_path("application.js") %>
```


# Install

    gem install rails2_asset_pipeline

    # config/environment.rb
    config.gem "rails2_asset_pipeline"

    # Rakefile
    begin
      require "rails2_asset_pipeline/tasks"
    rescue LoadError
      puts "rails2_asset_pipeline is not installed, you probably should run 'rake gems:install' or 'bundle install'."
    end

## Initializer
Here you can do additional configuration of sprockets.

```Ruby
# config/initializers/rails2_asset_pipeline.rb
Rails2AssetPipeline.setup do |sprockets|
  # ... additional config ...
end
```

## config.ru
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

## View helpers
```
# app/helpers/application_helper.rb
require 'rails2_asset_pipeline/view_helpers'
module ApplicationHelper
  include Rails2AssetPipeline::ViewHelpers
  ...
end
```


# Tasks

    rake assets:precompile
    rake assets:clean

## Todo
 - read config from Rails 3 style config.assets
 - `rake assets:clobber` to remove old assets
 - asset helpers for inside css/scss

Author
======
[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
License: MIT<br/>
[![Build Status](https://secure.travis-ci.org/grosser/rails2_asset_pipeline.png)](http://travis-ci.org/grosser/rails2_asset_pipeline)
