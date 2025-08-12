Gem::Specification.new do |s|
  s.name = 'apimatic_core'
  s.version = '0.3.19'
  s.summary = 'A library that contains apimatic-apimatic-core logic and utilities for consuming REST APIs using Python SDKs generated '\
              'by APIMatic.'
  s.description = 'The APIMatic Core libraries provide a stable runtime that powers all the functionality of SDKs.'\
                  ' This includes functionality like the ability to create HTTP requests, handle responses, apply '\
                  'authentication schemes, convert API responses back to object instances, and validate user and '\
                  'server data.'
  s.authors = ['APIMatic Ltd.']
  s.email = 'support@apimatic.io'
  s.homepage = 'https://apimatic.io'
  s.license = 'MIT'
  s.add_dependency('apimatic_core_interfaces', '~> 0.2.0')
  s.add_dependency('nokogiri', '~> 1.13', '>=1.13.10')
  s.add_dependency('certifi', '~> 2018.1', '>= 2018.01.18')
  s.add_dependency('faraday-multipart', '~> 1.0')
  s.add_development_dependency('faraday', '~> 2.8', '>= 2.8.1')
  s.add_development_dependency('minitest', '~> 5.25', '>= 5.25.4')
  s.add_development_dependency('minitest-proveit', '~> 1.0')
  s.add_development_dependency('simplecov', '~> 0.22.0')
  s.required_ruby_version = ['>= 2.6']
  s.files = Dir['{lib, test}/**/*', 'README*', 'LICENSE*']
  s.require_paths = ['lib']
end
