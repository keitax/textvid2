require 'textvid/entity'
require 'textvid/router'
require 'textvid/query'

RSpec.describe Textvid::Router do
  let(:router) { Textvid::Router.new('http://localhost:8000/root/') }

  describe '#root_url' do
    subject { router.root_url }
    it { is_expected.to eq URI('http://localhost:8000/root/') }
  end

  describe '#post_url' do
    subject { router.post_url(post) }

    context 'with url_title' do
      let(:post) do
        p = Textvid::Post.new
        p.id = 1000
        p.created_at = Time.local(2016, 1, 1)
        p.url_title = 'test post'
        p
      end
      it { is_expected.to eq URI('http://localhost:8000/root/2016/01/test%20post.html') }
    end

    context 'without url_title' do
      let(:post) do
        p = Textvid::Post.new
        p.id = 1100
        p
      end
      it { is_expected.to eq URI('http://localhost:8000/root/posts/1100') }
    end
  end

  describe '#post_list_url' do
    subject { router.post_list_url(query) }

    context 'given nil query' do
      let(:query) { Textvid::Query.new }
      it { is_expected.to eq URI('http://localhost:8000/root/posts/') }
    end

    context 'given range query' do
      let(:query) do
        q = Textvid::Query.new
        q.label = 'text vid'
        q.start = 1
        q.results = 2
        q
      end
      it { is_expected.to eq URI('http://localhost:8000/root/posts/?label=text%20vid&start=1&results=2') }
    end
  end
end
