require 'fileutils'
require 'minitest/autorun'

require 'textvid/entity'
require 'textvid/database'

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

    ps = @database.select(start: 1, results: 2)
    assert_equal([4, 3], ps.map(&:id))
  end

  def test_insert
    p = Post.new
    p.title = 'hello'
    p.body = 'hello, word'
    p.labels = %w(a b c)

    @database.insert(p) # id=1
    assert_equal(1, p.id, 'the post id is set')

    @database.insert(p) # id=2
    @database.insert(p) # id=3
    p3 = @database.get(3)
    assert_equal(3, p3.id)
    assert_equal(%w(a b c), p3.labels)
  end

  def test_update
    p = Post.new
    p.id = 10
    p.title = 'hello'
    p.body = 'hello, world'
    p.labels = %w(a b)

    @database.update(p)
    updated = @database.get(10)
    assert_equal(p.id, updated.id)
    assert_equal(p.title, updated.title)
    assert_equal(p.body, updated.body)
    assert_equal(p.labels, updated.labels)
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
