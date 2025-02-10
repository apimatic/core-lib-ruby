# typed: true
module CoreLibrary
  # A utility to allow users to set the content-type for files
  class FileWrapper
    extend T::Sig  # For Sorbet signature support

    attr_reader :content_type, :file

    # Initializes a new instance of FileWrapper.
    # @param [File] file File to enclose within file wrapper.
    # @param [String] content_type Content type of file.
    sig { params(file: File, content_type: T.nilable(String)).void }
    def initialize(file, content_type: 'application/octet-stream')
      @file = file
      @content_type = content_type
    end
  end
end
