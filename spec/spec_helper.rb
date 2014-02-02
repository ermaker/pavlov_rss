# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
if ENV['COVERAGE']
  require 'simplecov'
  formatters = [SimpleCov::Formatter::HTMLFormatter]
  begin
    puts '[COVERAGE] Running with SimpleCov HTML Formatter'
    require 'simplecov-rcov-text'
    formatters << SimpleCov::Formatter::RcovTextFormatter
    puts '[COVERAGE] Running with SimpleCov Rcov Formatter'
  rescue LoadError
    puts '[COVERAGE] SimpleCov Rcov formatter could not be loaded'
  end
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[ *formatters ]
  SimpleCov.start
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end

def feed fn
  File.read(File.join(File.dirname(__FILE__), 'fixtures', fn))
end

def sample_feed
  feed 'sample_feed.xml'
end