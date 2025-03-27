require 'tempfile'
require 'open-uri'

module CoreLibrary
  # A utility for file-specific operations.
  class FileHelper
    @cache = {}

    # Class method which takes a URL, downloads the file (if not already downloaded
    # for this test session), and returns the file path.
    # @param [String] url The URL of the required file.
    # @return [String] The path of the downloaded file.
    def self.get_file(url)
      return @cache[url] if @cache.key?(url)

      tempfile = Tempfile.new('APIMatic')
      tempfile.binmode
      tempfile.write(URI.parse(url).open(ssl_ca_cert: Certifi.where).read)
      tempfile.flush
      tempfile.close

      raise "Tempfile path is nil!" if tempfile.path.nil?

      @cache[url] = tempfile.path.to_s # Store only the file path
    end
  end
end
