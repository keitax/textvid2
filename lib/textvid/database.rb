require 'dbm'
require 'json'
require 'time'

require 'textvid/entity'

module Textvid
  class Database
    def self.create(db_dir)
      Dir.mkdir(db_dir) unless Dir.exist?(db_dir)
      dbm = DBM.new("#{db_dir}/posts", 0644, DBM::WRCREAT)
      Database.new(dbm)
    end

    def initialize(dbm)
      @dbm = dbm
    end

    def get(id)
      json = @dbm[id.to_s]
      return nil unless json
      h = JSON.parse(json)
      p = Post.new
      p.id = id
      p.created_at = Time.iso8601(h['created_at']) if h['created_at']
      p.updated_at = Time.iso8601(h['updated_at']) if h['updated_at']
      p.title = h['title']
      p.url_title = h['url_title']
      p.body = h['body']
      p.labels = h['labels']
      p
    end

    def get_neighbors(id)
      post_ids = saved_post_ids
      newer = nil
      older = nil
      if pos = post_ids.index(id)
        newer = get(post_ids[pos - 1]) if pos - 1 >= 0
        older = get(post_ids[pos + 1]) if pos + 1 < post_ids.length
      end
      [newer, older]
    end

    def select(query)
      candidate_ids = saved_post_ids
      if query.year && query.month
        candidate_ids = filter_by_month(candidate_ids, query.year, query.month)
      end
      if query.url_title
        candidate_ids = filter_by_url_title(candidate_ids, query.url_title)
      end
      start = (query.start || 1) - 1
      results = query.results || 5
      post_ids = candidate_ids[start...(start + results)]
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
          'created_at' => post.created_at&.iso8601,
          'updated_at' => post.updated_at&.iso8601,
          'title' => post.title,
          'url_title' => post.url_title,
          'body' => post.body,
          'labels' => post.labels
      }
      @dbm[post.dbm_key] = h.to_json
    end

    def delete(post)
      @dbm.delete(post.dbm_key)
    end

    private

    def filter_by_month(post_ids, year, month)
      target_month = [year, month]

      from_l = 0
      from_r = post_ids.length
      while from_l < from_r
        pivot = (from_l + from_r) / 2
        post = get(post_ids[pivot])
        pivot_month = [post.created_at.year, post.created_at.month]
        if (pivot_month <=> target_month) > 0
          from_l = pivot + 1
        else
          from_r = pivot
        end
      end
      from = from_l

      to_l = from
      to_r = post_ids.length
      while to_l < to_r
        pivot = (to_l + to_r) / 2
        post = get(post_ids[pivot])
        pivot_month = [post.created_at.year, post.created_at.month]
        if (pivot_month <=> target_month) < 0
          to_r = pivot
        else
          to_l = pivot + 1
        end
      end
      to = to_r

      post_ids[from...to]
    end

    def filter_by_url_title(post_ids, url_title)
      post_ids.select { |id|
        get(id).url_title == url_title
      }
    end

    def saved_post_ids
      @dbm.keys.map(&:to_i).sort { |l, r| r <=> l }
    end
  end
end
