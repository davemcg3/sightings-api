source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.4.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.1'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

# Use Rack Attack for whitelisting, blacklisting, and throttling
gem 'rack-attack'

# Use Swagger for API Documentation
gem 'swagger-docs'

# Use jwt for user auth
gem 'jwt'

# Use serializers
gem 'active_model_serializers'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  # Use rspec for testing
  gem 'rspec-rails'

  # Use factory bot for instantiating models during testing
  gem 'factory_bot_rails'

  # Use database cleaner to keep specs pollution-free
  # gem 'database_cleaner'

  # Use rubocop for code normalization
  gem 'rubocop'

  # Use simplecov for code coverage
  gem 'simplecov'

  gem 'awesome_print'

  # Use reek for identifying code smells
  # gem 'reek'

  # gem 'brakeman'

  # Use bundler audit to scan for security vulnerabilities
  # gem 'bundler-audit'

  # gem 'fixme'
  # gem 'duplication'
  # gem 'timecop'
  # gem 'faker'
  gem 'shoulda-matchers'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
end


# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
