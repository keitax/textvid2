require 'minitest/autorun'
require 'uri'

require 'textvid/database'
require 'textvid/entity'
require 'textvid/router'

class RouterTest < Minitest::Test
  include Textvid

  def setup
    @router = Router.new('http://localhost:8000/root/')
  end

  def test_post_url
    post_with_url_title = Post.new
    post_with_url_title.id = 1000
    post_with_url_title.created_at = Time.local(2016, 1, 1)
    post_with_url_title.url_title = 'test post'

    post_without_url_title = Post.new
    post_without_url_title.id = 1100

    assert_equal(URI('http://localhost:8000/root/2016/01/test%20post.html'), @router.post_url(post_with_url_title))
    assert_equal(URI('http://localhost:8000/root/posts/1100'), @router.post_url(post_without_url_title))
  end

  def test_post_list_url
    nil_query = Database::Query.new
    assert_equal(URI('http://localhost:8000/root/posts/'), @router.post_list_url(nil_query))

    specified_query = Database::Query.new
    specified_query.label = 'text vid'
    specified_query.start = 1
    specified_query.results = 2
    assert_equal(URI('http://localhost:8000/root/posts/?label=text%20vid&start=1&results=2'), @router.post_list_url(specified_query))
  end
end
