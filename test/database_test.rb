require 'fileutils'
require 'minitest/autorun'

require 'textvid/entity'
require 'textvid/database'
require 'textvid/query'

class DatabaseTest < Minitest::Test
  include Textvid
  include Minitest::Assertions

  TEMP_DB_DIR = './temp-db'

  def setup
    FileUtils.rmtree(TEMP_DB_DIR)
    @database = Database.create(TEMP_DB_DIR)
  end

  def test_get
    assert_nil(@database.get(1), 'gets nil when no post is found')
  end

  def test_select
    5.times do |i|
      p = Post.new
      p.title = "Title #{i}"
      p.body = "Body #{i}"
      p.labels = ["Label #{i}"]
      @database.insert(p)
    end

    q = Query.new
    q.start = 1
    q.results = 2
    ps = @database.select(q)
    assert_equal([4, 3], ps.map(&:id))
  end

  def test_select_by_month
    5.times do |i|
      p = Post.new
      p.title = "Title #{i}"
      p.created_at = Time.local(2016, 1, i + 1)
      @database.insert(p)
    end
    5.times do |i|
      p = Post.new
      p.title = "Title #{i}"
      p.created_at = Time.local(2016, 2, i + 1)
      @database.insert(p)
    end
    5.times do |i|
      p = Post.new
      p.title = "Title #{i}"
      p.created_at = Time.local(2016, 3, i + 1)
      @database.insert(p)
    end
    q = Query.new
    q.start = 0
    q.results = 999
    q.year = 2016
    q.month = 2
    results = @database.select(q)
    assert_equal(5, results.size)
    assert_equal(2, results.first.created_at.month)
    assert_equal(2, results.last.created_at.month)
  end

  def test_insert
    p = Post.new
    p.title = 'hello'
    p.body = 'hello, word'
    p.labels = %w(a b c)
    p.created_at = Time.local(2016, 1, 1)
    p.updated_at = Time.local(2016, 12, 31)

    @database.insert(p) # id=1
    assert_equal(1, p.id, 'the post id is set')

    @database.insert(p) # id=2
    @database.insert(p) # id=3
    p3 = @database.get(3)
    assert_equal(3, p3.id)
  end

  def test_update
    p = Post.new
    p.id = 10
    p.title = 'hello'
    p.url_title = 'hello-world'
    p.body = 'hello, world'
    p.labels = %w(a b)
    p.created_at = Time.local(2016, 1, 1)
    p.updated_at = Time.local(2016, 12, 31)

    @database.update(p)
    updated = @database.get(10)
    assert_equal(p.id, updated.id)
    assert_equal(p.title, updated.title)
    assert_equal(p.url_title, updated.url_title)
    assert_equal(p.body, updated.body)
    assert_equal(p.labels, updated.labels)
    assert_equal(p.created_at, updated.created_at)
    assert_equal(p.updated_at, updated.updated_at)
  end

  def test_delete
    p = Post.new
    p.title = 'hello'
    p.body = 'hello, world'
    p.labels = []

    @database.insert(p)
    assert @database.get(1)

    @database.delete(p)
    assert_nil @database.get(1)
  end
end
