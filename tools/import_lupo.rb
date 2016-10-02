require 'sqlite3'

require 'textvid/database'
require 'textvid/entity'

tv_db = Textvid::Database.create('./textvid-db')
lupo_db = SQLite3::Database.new('../../Downloads/20160517-production.sqlite3')

query = <<QUERY
SELECT
  E.ID,
  E.CREATED_AT,
  E.MODIFIED_AT,
  E.DAY,
  E.TITLE,
  E.BODY
FROM ENTRIES E
ORDER BY E.CREATED_AT ASC
QUERY

lupo_db.execute(query) do |row|
  id, created_at, modified_at, day, title, body = row
  p = Textvid::Post.new
  p.id = id
  p.created_at = Time.parse(created_at)
  p.updated_at = Time.parse(modified_at)
  p.title = title
  p.body = body
  p.labels = []
  tv_db.insert(p)
end
