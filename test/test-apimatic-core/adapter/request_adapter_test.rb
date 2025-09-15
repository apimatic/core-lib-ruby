require "minitest/autorun"
require 'apimatic_core'
require_relative "../../test-helper/adapter/rack_request_mock"
require_relative "../../test-helper/adapter/hanami_request_mock"
require_relative "../../test-helper/adapter/rails_request_mock"
require_relative "../../test-helper/adapter/local_proxy_helper"

class RequestAdapterTest < Minitest::Test
  include CoreLibrary, TestComponent

  # -------------------------
  # Rails branch
  # -------------------------
  def test_from_rails_basic_request
    req = TestComponent::ActionDispatch::Request.new(
      method: "GET",
      path: "/rails/basic",
      url: "http://localhost/rails/basic",
      headers: { "HTTP_CONTENT_TYPE" => "application/json" },
      query: { "q" => "1" },
      cookies: { "sid" => "xyz" },
      body: "hello world"
    )

    snap = RequestAdapter.to_unified_request(req)
    assert_equal "GET", snap.method
    assert_equal "/rails/basic", snap.path
    assert_equal "http://localhost/rails/basic", snap.url
    assert_equal({ "Content-Type" => "application/json" }, snap.headers)
    assert_equal({ "q" => ["1"] }, snap.query)
    assert_equal({ "sid" => "xyz" }, snap.cookies)
    assert_equal "hello world", snap.raw_body
  end

  def test_from_rails_form_request
    req = TestComponent::ActionDispatch::Request.new(
      method: "POST",
      path: "/rails/form",
      url: "http://localhost/rails/form",
      form: { "name" => "Maryam" },
      query: { "x" => "9" }
    )

    snap = RequestAdapter.to_unified_request(req)
    assert_equal "POST", snap.method
    assert_equal "/rails/form", snap.path
    assert_equal "http://localhost/rails/form", snap.url
    # Rails keeps query separate
    assert_equal({ "x" => ["9"] }, snap.query)
    assert_equal({ "name" => ["Maryam"] }, snap.form)
  end

  # -------------------------
  # Rack branch
  # -------------------------
  def test_from_rack_basic_request
    req = TestComponent::Rack::Request.new(
      method: "GET",
      path: "/rack/basic",
      url: "http://localhost/rack/basic",
      headers: { "HTTP_ACCEPT" => "text/plain" },
      query: { "foo" => "bar" },
      cookies: { "cid" => "abc" },
      body: "rack-body"
    )

    snap = RequestAdapter.to_unified_request(req)
    assert_equal "GET", snap.method
    assert_equal "/rack/basic", snap.path
    assert_equal "http://localhost/rack/basic", snap.url
    assert_equal({ "Accept" => "text/plain" }, snap.headers)
    assert_equal({ "foo" => ["bar"] }, snap.query)
    assert_equal({ "cid" => "abc" }, snap.cookies)
    assert_equal "rack-body", snap.raw_body
  end

  def test_from_rack_form_request
    req = TestComponent::Rack::Request.new(
      method: "POST",
      path: "/rack/form",
      url: "http://localhost/rack/form",
      form: { "age" => "25" },
      query: { "x" => "100" }
    )

    snap = RequestAdapter.to_unified_request(req)
    assert_equal "POST", snap.method
    assert_equal "/rack/form", snap.path
    assert_equal "http://localhost/rack/form", snap.url
    assert_equal({ "x" => ["100"] }, snap.query)
    assert_equal({ "age" => ["25"] }, snap.form)
  end

  # -------------------------
  # Hanami branch
  # -------------------------
  def test_from_hanami_basic_request
    req = TestComponent::Hanami::Action::Request.new(
      method: "GET",
      path: "/hanami/basic",
      url: "http://localhost/hanami/basic",
      headers: { "HTTP_X_CUSTOM" => "yes" },
      query: { "p" => "1" },
      cookies: { "cookie_a" => "cookie-val" },
      body: "hanami-body"
    )

    snap = RequestAdapter.to_unified_request(req)
    assert_equal "GET", snap.method
    assert_equal "/hanami/basic", snap.path
    assert_equal "http://localhost/hanami/basic", snap.url
    assert_equal({ "X-Custom" => "yes" }, snap.headers)
    assert_equal({ "p" => ["1"] }, snap.query)
    assert_equal({ "cookie_a" => "cookie-val" }, snap.cookies)
    assert_equal "hanami-body", snap.raw_body
  end

  def test_from_hanami_form_request_merges_query
    req = TestComponent::Hanami::Action::Request.new(
      method: "POST",
      path: "/hanami/form",
      url: "http://localhost/hanami/form",
      form: { "name" => "Maryam" },
      query: { "id" => "42" }
    )

    snap = RequestAdapter.to_unified_request(req)
    assert_equal "POST", snap.method
    assert_equal "/hanami/form", snap.path
    assert_equal "http://localhost/hanami/form", snap.url
    # Hanami merges query + form into one param hash
    assert_equal({ "id" => ["42"], "name" => ["Maryam"] }, snap.form)
  end

  # -------------------------
  # LocalProxy unwrap
  # -------------------------
  def test_unwrap_local_proxy_success
    real_req = TestComponent::Rack::Request.new(path: "/proxy-ok")
    proxy = LocalProxyLike.new(real_req)

    snap = RequestAdapter.to_unified_request(proxy)
    assert_equal "/proxy-ok", snap.path
  end

  def test_unwrap_local_proxy_raises_and_falls_back
    proxy = LocalProxyRaising.new

    assert_raises(TypeError) do
      RequestAdapter.to_unified_request(proxy)
    end
  end

  # -------------------------
  # Unsupported type
  # -------------------------
  def test_rejects_unsupported_type
    assert_raises(TypeError) do
      RequestAdapter.to_unified_request("not-a-request")
    end
  end


  # -------------------------
  # normalize_params
  # -------------------------
  def test_normalize_params_handles_nil_and_scalars
    assert_nil RequestAdapter.send(:normalize_params, nil)
    assert_equal({ "a" => ["1"] }, RequestAdapter.send(:normalize_params, { "a" => "1" }))
    assert_equal({ "b" => %w[x y] }, RequestAdapter.send(:normalize_params, { "b" => %w[x y] }))
  end
end
