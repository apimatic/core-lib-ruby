require 'minitest/autorun'
require 'apimatic_core'

class ProxySettingsTest < Minitest::Test
  include CoreLibrary

  # -------------------------------
  # Tests for ProxySettings.to_h
  # -------------------------------
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

  # -------------------------------
  # Tests for ProxySettings.from_hash
  # -------------------------------

  def test_from_hash_creates_instance_with_all_fields
    hash = {
      address: 'http://proxy.local',
      port: 3128,
      username: 'user',
      password: 'pass'
    }

    proxy = ProxySettings.from_hash(hash)
    refute_nil proxy
    assert_equal 'http://proxy.local', proxy.address
    assert_equal 3128, proxy.port
    assert_equal 'user', proxy.username
    assert_equal 'pass', proxy.password
  end

  def test_from_hash_supports_string_keys
    hash = {
      'address' => 'http://proxy.example',
      'port' => 8080,
      'username' => 'bob',
      'password' => 'secret'
    }

    proxy = ProxySettings.from_hash(hash)
    refute_nil proxy
    assert_equal 'http://proxy.example', proxy.address
    assert_equal 8080, proxy.port
    assert_equal 'bob', proxy.username
    assert_equal 'secret', proxy.password
  end

  def test_from_hash_returns_nil_for_nil_input
    assert_nil ProxySettings.from_hash(nil)
  end

  def test_from_hash_returns_nil_for_empty_hash
    assert_nil ProxySettings.from_hash({})
  end

  def test_from_hash_returns_nil_when_address_is_missing
    hash = { port: 8080, username: 'x', password: 'y' }
    assert_nil ProxySettings.from_hash(hash)
  end

  def test_from_hash_returns_nil_when_address_is_empty_string
    hash = { address: '', port: 8080 }
    assert_nil ProxySettings.from_hash(hash)
  end
end
