require 'minitest/autorun'

require 'textvid/query'

class QueryTest < Minitest::Test
  include Textvid

  def test_previous
    q = Query.new
    q.start = 1
    assert_nil(q.previous)

    q = Query.new
    q.results = 1
    assert_nil(q.previous)

    q = Query.new
    q.start = 2
    q.results = 2
    assert_equal(1, q.previous.start)
    assert_equal(1, q.previous.results)

    q = Query.new
    q.start = 3
    q.results = 2
    assert_equal(1, q.previous.start)
    assert_equal(2, q.previous.results)
  end

  def test_next
    q = Query.new
    q.start = 1
    assert_nil(q.next)

    q = Query.new
    q.results = 1
    assert_nil(q.next)

    q = Query.new
    q.start = 1
    q.results = 2
    assert_equal(3, q.next.start)
    assert_equal(2, q.next.results)
  end
end
