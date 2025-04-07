require 'tempfile'
require 'open-uri'

module CoreLibrary
  # A utility for file-specific operations.
  class FileHelper
    @cache = {}

    # Class method which takes a URL, downloads the file (if not already downloaded
    # for this test session), and returns the file path.
    # @param [String] url The URL of the required file.
    # @return [Tempfile] The downloaded file.
    def self.get_file(url)
      if @cache.key?(url)
        @cache[url].rewind
        return @cache[url]
      end

      tempfile = Tempfile.new('APIMatic')
      tempfile.binmode
      tempfile.write(URI.parse(url).open(ssl_ca_cert: Certifi.where).read)
      tempfile.flush

      @cache[url] = tempfile
    end
  end
end
