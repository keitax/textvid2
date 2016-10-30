require 'uri'

module Textvid
  class Router
    def initialize(root_path)
      @root_path = root_path
    end

    def root_url
      URI(@root_path)
    end

    def post_url(post)
      if !post.url_title || post.url_title.empty?
        return URI.join(@root_path, "posts/#{post.id}") unless post.url_title
      end
      post_path = format('%02d/%02d/%s.html', post.created_at.year, post.created_at.month, post.url_title)
      URI.join(@root_path, URI.encode(post_path))
    end

    def post_list_url(selector)
      params = []
      params.push("label=#{URI.encode(selector.label)}") if selector.label
      params.push("start=#{selector.start}") if selector.start
      params.push("results=#{selector.results}") if selector.results
      return URI.join(@root_path, 'posts/') if params.empty?
      URI.join(@root_path, 'posts/', "?#{params.join('&')}")
    end
  end
end
