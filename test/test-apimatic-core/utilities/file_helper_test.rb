require 'minitest/autorun'
require 'apimatic_core'

class FileHelperTest < Minitest::Test
  include CoreLibrary
  def setup
  end

  def teardown
    # Do nothing
  end

  def test_get_file
    file_url = 'https://gist.githubusercontent.com/asadali214/' \
                   '0a64efec5353d351818475f928c50767/raw/8ad3533799ecb4e01a753aaf04d248e6702d4947/testFile.txt'
    expected_file_content = 'This test file is created to test CoreFileWrapper functionality'

    File::open(FileHelper.get_file(file_url)) do |actual_file|
      refute_nil actual_file
      assert_equal expected_file_content.encode('ascii'), actual_file.read()
    end

  end
end
