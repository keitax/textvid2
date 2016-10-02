require 'yaml'

require 'textvid/entity'

module Textvid
  class Database
    def self.create(db_dir)
      Dir.mkdir(db_dir) unless Dir.exist?(db_dir)
      Database.new(db_dir)
    end

    def initialize(db_dir)
      @db_dir = db_dir
    end

    def get(id)
      path = post_path(id)
      return nil unless File.exist?(path)
      h = YAML.load_file(post_path(id))
      p = Post.new
      p.id = id
      p.created_at = h['created_at']
      p.updated_at = h['updated_at']
      p.title = h['title']
      p.url_title = h['url_title']
      p.body = h['body']
      p.labels = h['labels']
      p
    end

    def select(query)
      start = query.start || 0
      results = query.results || 5
      post_ids = saved_post_ids[start...start + results]
      post_ids.map { |id| get(id) }
    end

    def insert(post)
      last_post_id = saved_post_ids.first || 0
      post.id = last_post_id + 1
      post.created_at = Time.now
      update(post)
    end

    def update(post)
      post.updated_at = Time.now
      h = {
          'id' => post.id,
          'created_at' => post.created_at,
          'updated_at' => post.updated_at,
          'title' => post.title,
          'url_title' => post.url_title,
          'body' => post.body,
          'labels' => post.labels
      }
      File.open(post_path(post.id), 'w') do |f|
        f.write(YAML.dump(h))
      end
    end

    def delete(post)
      File.delete(post_path(post.id))
    end

    private

    def saved_post_ids
      post_filenames = Dir.new(@db_dir).entries.select { |entry| /\d+/ =~ entry }
      post_filenames.map(&:to_i).sort { |l, r| r <=> l }
    end

    def post_path(id)
      File.join(@db_dir, id.to_s)
    end
  end
end
