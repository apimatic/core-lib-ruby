# typed: strict
require 'sorbet-runtime'
require 'tempfile'
require 'open-uri'

# typed: strict

module CoreLibrary
  # A utility for file-specific operations.
  class FileHelper
    extend T::Sig

    @cache = T.let({}, T::Hash[String, Tempfile])

    # Class method which takes a URL, downloads the file (if not already downloaded
    # for this test session) and returns the path of the file.
    # @param [String] url The URL of the required file.
    # @return [String] The path of the downloaded file.
    sig { params(url: String).returns(String) }
    def self.get_file(url)
      unless @cache.key?(url)
        tempfile = Tempfile.new('APIMatic')
        tempfile.binmode
        tempfile.write(URI.open(url, ssl_ca_cert: Certifi.where).read)
        tempfile.rewind
        @cache[url] = tempfile
      end
      @cache[url].path
    end
  end
end
