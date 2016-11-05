require 'sinatra/base'
require 'erb'
require 'forwardable'

require 'textvid/database'
require 'textvid/query'

module Textvid
  class Application < Sinatra::Base
    include ERB::Util

    extend Forwardable
    def_delegator :settings, :database
    def_delegator :settings, :router

    POSTS_PER_PAGE = 5

    get '/' do
      render_posts(default_query)
    end

    get '/posts/:id' do
      post = database.get(params[:id].to_i)
      if post && post.url_title
        redirect to(router.post_url(post).path)
      elsif post
        @post = post
        @newer_post, @older_post = database.get_neighbors(@post.id)
        erb :post
      else
        pass
      end
    end

    get '/posts/' do
      query = default_query
      query.start = params['start'].to_i if params['start']
      query.results = params['results'].to_i if params['results']
      render_posts(query)
    end

    get %r<(\d{4})/(\d{2})/(.+)\.html> do
      year_param, month_param, url_title = params['captures']
      q = Query.new
      q.start = 1
      q.results = 1
      q.year = year_param.to_i
      q.month = month_param.to_i
      q.url_title = url_title
      posts = database.select(q)
      unless posts.empty?
        @post = posts.first
        @newer_post, @older_post = database.get_neighbors(@post.id)
        erb :post
      end
    end

    private

    def render_posts(query)
      @posts = database.select(query)
      @newer_posts = database.select(query.previous)
      @older_posts = database.select(query.next)
      @query = query
      erb :index
    end

    def default_query
      q = Query.new
      q.start = 1
      q.results = POSTS_PER_PAGE
      q
    end
  end
end
