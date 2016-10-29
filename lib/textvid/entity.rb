require 'textvid/parser'

module Textvid
  class Post
    attr_accessor :id, :created_at, :updated_at, :title, :url_title, :body, :labels

    def dbm_key
      return nil unless @id
      @id.to_s
    end

    def rendered_body
      Parser.parse(body)
    end
  end
end
