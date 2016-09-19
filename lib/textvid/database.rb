require 'yaml'

require 'textvid/entity'

module Textvid
  class Database
    Query = Struct.new(:words, :labels, :start, :results)

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
      p.title = h['title']
      p.body = h['body']
      p.labels = h['labels']
      p
    end

    def select(start: 0, results: 5)
      post_ids = saved_post_ids[start...start + results]
      post_ids.map { |id| get(id) }
    end

    def insert(post)
      last_post_id = saved_post_ids.first || 0
      post.id = last_post_id + 1
      update(post)
    end

    def update(post)
      h = {
          'id' => post.id,
          'title' => post.title,
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
