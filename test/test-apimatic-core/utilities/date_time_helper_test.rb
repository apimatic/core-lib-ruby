require 'minitest/autorun'
require 'apimatic_core'

class DateTimeHelperTest < Minitest::Test
  include CoreLibrary
  def setup
  end

  def teardown
    # Do nothing
  end

  def test_to_rfc1123
    dt_in_utc = Time.utc(2018, 1, 1, 5, 15, 30)
    actual_dt = DateTimeHelper.to_rfc1123(dt_in_utc)
    expected_dt = dt_in_utc.httpdate

    refute_nil actual_dt
    assert_equal expected_dt, actual_dt
  end

  def test_to_rfc1123_array
    dt_array_in_utc = [Time.utc(2018, 1, 1, 5, 15, 30).to_datetime, Time.utc(2019, 1, 1, 5, 15, 30).to_datetime]
    hash = {}
    key = 'dt'
    actual_dt = DateTimeHelper.to_rfc1123_array(dt_array_in_utc, hash, key)
    expected_dt = dt_array_in_utc.map { |element| element.httpdate}

    refute_nil actual_dt
    assert_equal expected_dt, actual_dt
  end

  def test_to_rfc1123_map
    dt_map_in_utc = {"dt1" => Time.utc(2018, 1, 1, 5, 15, 30).to_datetime, "dt2" => Time.utc(2019, 1, 1, 5, 15, 30).to_datetime}
    hash = {}
    key = 'dt'
    actual_dt = DateTimeHelper.to_rfc1123_map(dt_map_in_utc, hash, key)
    expected_dt = {}
    dt_map_in_utc.each { |k, v| expected_dt[k] = v.httpdate}

    refute_nil actual_dt
    assert_equal expected_dt, actual_dt
  end

  def test_to_unix
    dt_in_utc = Time.utc(2018, 1, 1, 5, 15, 30)
    actual_dt = DateTimeHelper.to_unix(dt_in_utc)
    expected_dt = dt_in_utc.to_i

    refute_nil actual_dt
    assert_equal expected_dt, actual_dt
  end

  def test_to_unix_array
    dt_array_in_utc = [Time.utc(2018, 1, 1, 5, 15, 30).to_datetime, Time.utc(2019, 1, 1, 5, 15, 30).to_datetime]
    hash = {}
    key = 'dt'
    actual_dt = DateTimeHelper.to_unix_array(dt_array_in_utc, hash, key)
    expected_dt = dt_array_in_utc.map { |element| element.to_time.to_i}

    refute_nil actual_dt
    assert_equal expected_dt, actual_dt
  end

  def test_to_unix_map
    dt_map_in_utc = {"dt1" => Time.utc(2018, 1, 1, 5, 15, 30).to_datetime, "dt2" => Time.utc(2019, 1, 1, 5, 15, 30).to_datetime}
    hash = {}
    key = 'dt'
    actual_dt = DateTimeHelper.to_unix_map(dt_map_in_utc, hash, key)
    expected_dt = {}
    dt_map_in_utc.each { |k, v| expected_dt[k] = v.to_time.to_i}

    refute_nil actual_dt
    assert_equal expected_dt, actual_dt
  end

  def test_to_rfc3339
    dt_in_utc = Time.utc(2018, 1, 1, 5, 15, 30).to_datetime
    actual_dt = DateTimeHelper.to_rfc3339(dt_in_utc)
    expected_dt = dt_in_utc.rfc3339

    refute_nil actual_dt
    assert_equal expected_dt, actual_dt
  end

  def test_to_rfc3339_array
    dt_array_in_utc = [Time.utc(2018, 1, 1, 5, 15, 30).to_datetime, Time.utc(2019, 1, 1, 5, 15, 30).to_datetime]
    hash = {}
    key = 'dt'
    actual_dt = DateTimeHelper.to_rfc3339_array(dt_array_in_utc, hash, key)
    expected_dt = dt_array_in_utc.map { |element| element.rfc3339}

    refute_nil actual_dt
    assert_equal expected_dt, actual_dt
  end

  def test_to_rfc3339_map
    dt_map_in_utc = {"dt1" => Time.utc(2018, 1, 1, 5, 15, 30).to_datetime, "dt2" => Time.utc(2019, 1, 1, 5, 15, 30).to_datetime}
    hash = {}
    key = 'dt'
    actual_dt = DateTimeHelper.to_rfc3339_map(dt_map_in_utc, hash, key)
    expected_dt = {}
    dt_map_in_utc.each { |k, v| expected_dt[k] = v.rfc3339}

    refute_nil actual_dt
    assert_equal expected_dt, actual_dt
  end

  def test_from_rfc1123
    dt_in_rfc1123 = 'Mon, 01 Jan 2018 05:15:30 GMT'
    actual_dt = DateTimeHelper.from_rfc1123(dt_in_rfc1123)
    expected_dt = Time.utc(2018, 1, 1, 5, 15, 30).to_datetime

    refute_nil actual_dt
    assert_equal expected_dt, actual_dt
  end

  def test_from_unix
    dt_in_rfc1123 = 1514783730
    actual_dt = DateTimeHelper.from_unix(dt_in_rfc1123)
    expected_dt = Time.utc(2018, 1, 1, 5, 15, 30).to_datetime

    refute_nil actual_dt
    assert_equal expected_dt, actual_dt
  end

  def test_from_rfc3339_without_timezone
    dt_in_rfc1123 = '2018-01-01T05:15:30'
    actual_dt = DateTimeHelper.from_rfc3339(dt_in_rfc1123)
    expected_dt = DateTime.parse(dt_in_rfc1123)

    refute_nil actual_dt
    assert_equal expected_dt, actual_dt
  end

  def test_from_rfc3339_with_timezone
    dt_in_rfc1123 = '2018-01-01T05:15:30Z'
    actual_dt = DateTimeHelper.from_rfc3339(dt_in_rfc1123)
    expected_dt = DateTime.parse(dt_in_rfc1123)

    refute_nil actual_dt
    assert_equal expected_dt, actual_dt
  end

  def test_from_rfc3339_zero_timezone_offset
    dt_in_rfc1123 = '2018-01-01T05:15:30+00:00'
    actual_dt = DateTimeHelper.from_rfc3339(dt_in_rfc1123)
    expected_dt = DateTime.parse(dt_in_rfc1123)

    refute_nil actual_dt
    assert_equal expected_dt, actual_dt
  end

  def test_from_rfc3339_negative_timezone_offset
    dt_in_rfc1123 = '2018-01-01T05:15:30-03:00'
    actual_dt = DateTimeHelper.from_rfc3339(dt_in_rfc1123)
    expected_dt = DateTime.parse(dt_in_rfc1123)

    refute_nil actual_dt
    assert_equal expected_dt, actual_dt
  end

  def test_from_rfc3339_positive_timezone_offset
    dt_in_rfc1123 = '2018-01-01T05:15:30+03:00'
    actual_dt = DateTimeHelper.from_rfc3339(dt_in_rfc1123)
    expected_dt = DateTime.parse(dt_in_rfc1123)

    refute_nil actual_dt
    assert_equal expected_dt, actual_dt
  end
end
