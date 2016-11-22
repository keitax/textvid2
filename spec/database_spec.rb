require 'textvid/database'
require 'textvid/entity'
require 'textvid/query'

RSpec.describe Textvid::Database do
  TEMP_DB_DIR = './temp-db'

  before(:each) do
    FileUtils.rmtree(TEMP_DB_DIR)
  end

  let(:database) { Textvid::Database.create(TEMP_DB_DIR) }

  describe '#get' do
    context 'without posts' do
      it 'returns nil' do
        expect(database.get(1)).to be_nil
      end
    end
  end

  describe '#get_neighbors' do
    subject(:newer) { database.get_neighbors(id)[0] }
    subject(:older) { database.get_neighbors(id)[1] }

    context 'with some posts' do
      before(:each) do
        3.times do |i|
          p = Textvid::Post.new
          p.title = "Title #{i + 1}"
          p.body = "Body #{i + 1}"
          p.labels = ["Label #{i + 1}"]
          database.insert(p)
        end
      end

      context 'specified newest id' do
        let(:id) { 3 }
        it { expect(newer).to be_nil }
        it { expect(older&.title).to eq 'Title 2' }
      end

      context 'specified oldest id' do
        let(:id) { 1 }
        it { expect(newer&.title).to eq 'Title 2' }
        it { expect(older).to be_nil }
      end

      context 'specified middle id' do
        let(:id) { 2 }
        it { expect(newer&.title).to eq 'Title 3' }
        it { expect(older&.title).to eq 'Title 1' }
      end
    end
  end

  describe '#select' do
    subject(:selected) { database.select(query) }
    subject(:selected_ids) { database.select(query)&.map(&:id) }

    context 'with five posts' do
      before(:each) do
        5.times do |i|
          p = Textvid::Post.new
          p.title = "Title #{i}"
          p.body = "Body #{i}"
          p.labels = ["Label #{i}"]
          database.insert(p)
        end
      end

      context 'basic query' do
        let(:query) do
          q = Textvid::Query.new
          q.start = 2
          q.results = 2
          q
        end
        it { expect(selected_ids).to eq [4, 3] }
      end

      context 'query.start is out of range' do
        let(:query) do
          q = Textvid::Query.new
          q.start = 0
          q.results = 2
          q
        end
        it { expect(selected_ids).to eq [5] }
      end

      context 'queried.result is larger than num of db has' do
        let(:query) do
          q = Textvid::Query.new
          q.start = 5
          q.results = 2
          q
        end
        it { expect(selected_ids).to eq [1] }
      end

      context 'queried.start is larger than num of db has' do
        let(:query) do
          q = Textvid::Query.new
          q.start = 6
          q.results = 1
          q
        end
        it { expect(selected_ids).to eq [] }
      end
    end

    context 'with posts within 2016-01 to 2016-03' do
      before(:each) do
        5.times do |i|
          p = Textvid::Post.new
          p.title = "Title #{i}"
          p.created_at = Time.local(2016, 1, i + 1)
          database.insert(p)
        end
        5.times do |i|
          p = Textvid::Post.new
          p.title = "Title #{i}"
          p.created_at = Time.local(2016, 2, i + 1)
          database.insert(p)
        end
        5.times do |i|
          p = Textvid::Post.new
          p.title = "Title #{i}"
          p.created_at = Time.local(2016, 3, i + 1)
          database.insert(p)
        end
      end

      context 'queried posts on 2016-02' do
        let(:query) do
          q = Textvid::Query.new
          q.start = 1
          q.results = 999
          q.year = 2016
          q.month = 2
          q
        end
        it { expect(selected.size).to eq 5 }
        it { expect(selected.first.created_at.month).to eq 2 }
        it { expect(selected.last.created_at.month).to eq 2 }
      end
    end

    context 'with three posts having url_title' do
      before(:each) do
        3.times do |i|
          p = Textvid::Post.new
          p.title = "Post #{i}"
          p.url_title = "post-#{i}"
          database.insert(p)
        end
      end

      context 'queried with url_title' do
        let(:query) do
          q = Textvid::Query.new
          q.url_title = 'post-1'
          q
        end
        it { expect(selected.size).to eq 1 }
        it { expect(selected&.first&.title).to eq 'Post 1' }
        it { expect(selected&.first&.url_title).to eq 'post-1' }
      end
    end
  end

  describe '#insert' do
    subject(:inserted) do
      database.get(1)
    end

    before do
      database.insert(post)
    end

    context 'given a post' do
      let(:post) do
        p = Textvid::Post.new
        p.title = 'hello'
        p.body = 'hello, world'
        p
      end
      it { expect(inserted&.title).to eq 'hello' }
    end
  end
end
