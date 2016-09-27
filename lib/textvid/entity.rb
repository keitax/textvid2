require 'textvid/parser'

module Textvid
  class Post
    attr_accessor :id, :created_at, :updated_at, :title, :body, :labels

    def rendered_body
      Parser.parse(body)
    end
  end
end
