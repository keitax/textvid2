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
      @posts = database.select(default_query)
      erb :index
    end

    private

    def default_query
      q = Query.new
      q.start = 1
      q.results = POSTS_PER_PAGE
      q
    end
  end
end
