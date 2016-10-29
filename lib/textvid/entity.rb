require 'json'

require 'textvid/parser'

module Textvid
  class Post
    attr_accessor :id, :created_at, :updated_at, :title, :url_title, :body, :labels

    def self.from_json(json)
      h = JSON.parse(json)
      p = self.new
      p.id = h['id']
      p.created_at = Time.iso8601(h['created_at']) if h['created_at']
      p.updated_at = Time.iso8601(h['updated_at']) if h['updated_at']
      p.title = h['title']
      p.url_title = h['url_title']
      p.body = h['body']
      p.labels = h['labels']
      p
    end

    def to_json
      h = {
          'id' => @id,
          'created_at' => @created_at&.iso8601,
          'updated_at' => @updated_at&.iso8601,
          'title' => @title,
          'url_title' => @url_title,
          'body' => @body,
          'labels' => @labels
      }
      h.to_json
    end

    def dbm_key
      return nil unless @id
      @id.to_s
    end

    def rendered_body
      Parser.parse(body)
    end
  end
end
