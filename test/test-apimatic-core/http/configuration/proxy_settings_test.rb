require 'minitest/autorun'
require 'apimatic_core'

class ProxySettingsTest < Minitest::Test
  include CoreLibrary

  def test_to_hash_includes_all_fields
    proxy = ProxySettings.new(
      address: 'http://localhost',
      port: 8080,
      username: 'user',
      password: 'pass'
    )

    assert_equal(
      {
        uri: 'http://localhost:8080',
        user: 'user',
        password: 'pass'
      },
      proxy.to_h
    )
  end

  def test_to_hash_excludes_username_and_password_when_nil
    proxy = ProxySettings.new(address: 'http://localhost', port: 8080)

    assert_equal({ uri: 'http://localhost:8080' }, proxy.to_h)
  end

  def test_to_hash_excludes_port_when_nil
    proxy = ProxySettings.new(address: 'http://localhost')

    assert_equal({ uri: 'http://localhost' }, proxy.to_h)
  end

  def test_initialize_raises_for_empty_address
    error = assert_raises(ArgumentError) do
      ProxySettings.new(address: '')
    end
    assert_match(/address must be a non-empty string/, error.message)
  end
end
