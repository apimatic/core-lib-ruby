require 'tempfile'
require 'open-uri'
module CoreLibrary
  # A utility for file specific operations.
  class FileHelper
    @cache = {}

    # Class method which takes a URL, downloads the file (if not already downloaded.
    # for this test session) and returns the path of the file.
    # @param [String] url The URL of the required file.
    def self.get_file(url)
      unless @cache.keys.include? url
        @cache[url] = Tempfile.new('APIMatic')
        @cache[url].binmode
        @cache[url].write(URI.parse(url).open({ ssl_ca_cert: Certifi.where }).read)
      end
      @cache[url].rewind
      @cache[url].path
    end
  end
end
