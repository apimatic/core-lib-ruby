require 'simplecov'
require "simplecov_json_formatter"

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([SimpleCov::Formatter::HTMLFormatter,
                                                                SimpleCov::Formatter::JSONFormatter])
SimpleCov.start do
  add_filter 'test'
  enable_coverage :branch
end

# test constants
TEST_TOKEN = 'MyDuMmYtOkEn'.freeze
JSON_CONTENT_TYPE = 'application/json'.freeze
FORM_PARAM_KEY = 'form_param'.freeze
TEST_EMAIL = 'test@gmail.com'