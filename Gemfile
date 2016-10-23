source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.0'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.15'
# Use Puma as the app server
gem 'puma', '~> 3.6'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# mailjet for marketing and transactional email
gem 'mailjet', '~> 1.4'

# For simple-to-use environment variables
gem "figaro", '~> 1.1'

# MaterializeCSS (http://materializecss.com/)
gem 'materialize-sass', '~> 0.97'
# Material Icons (https://design.google.com/icons/)
gem 'material_icons'

# New Relic for performance analysis
gem 'newrelic_rpm', '~> 3.16'

# Nokogiri for parsing fields with errors
gem "nokogiri", '~> 1.6'

group :development, :test do
  # We will use pry rails as our console
  gem 'pry-rails'
  # and also as our debugger
  gem 'pry-byebug'
  # We will use bullet to avoid N+1 queries
  gem 'bullet', '~> 5.2.0'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  gem 'listen', '~> 3.0.5'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Automatically run tests when files update
  gem 'guard-rspec', '~> 4.7', require: false

  gem 'capistrano',         require: false
  gem 'capistrano-rvm',     require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano3-puma',   require: false
  gem 'capistrano-figaro-yml', '~> 1.0.2', require: false
  gem 'capistrano-rails-console', '~> 1.0.2', require: false
end

group :test do
  # Add rake for Travis CI
  gem 'rake', '~> 11.2'
  # Better testing
  gem 'rspec-rails', '~> 3.5'
  # Testing controllers for rendered template and variables
  gem 'rails-controller-testing', '~> 1.0'
  # Automatically generate testing models
  gem 'factory_girl_rails', '~> 4.7'
  # Quickly generate fake names, urls, etc
  gem 'faker', '~> 1.6'
  # BDD testing
  gem 'capybara-webkit', '~> 1.11'
  # A few extra testing matchers
  gem 'shoulda-matchers', '~> 3.1', require: false
  # Cleans the test database after every test
  gem 'database_cleaner', '~> 1.5'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
