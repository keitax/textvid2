require 'textvid/query'

RSpec.describe Textvid::Query do
  describe '#previous' do
    subject { query.previous }

    context 'query.results is missed' do
      let(:query) do
        q = Textvid::Query.new
        q.start = 1
        q
      end
      it { is_expected.to be_nil }
    end

    context 'query.start is missed' do
      let(:query) do
        q = Textvid::Query.new
        q.results = 1
        q
      end
      it { is_expected.to be_nil }
    end

    context 'query.results >= query.start' do
      let(:query) do
        q = Textvid::Query.new
        q.start = 2
        q.results = 2
        q
      end
      it { expect(subject.start).to eq 1 }
      it { expect(subject.results).to eq 1 }
    end

    context 'query.results < query.start' do
      let(:query) do
        q = Textvid::Query.new
        q.start = 3
        q.results = 2
        q
      end
      it { expect(subject.start).to eq 1 }
      it { expect(subject.results).to eq 2 }
    end
  end

  describe '#next' do
    subject { query.next }

    context 'query.results is missed' do
      let(:query) do
        q = Textvid::Query.new
        q.start = 1
        q
      end
      it { is_expected.to be_nil }
    end

    context 'query.start is missed' do
      let(:query) do
        q = Textvid::Query.new
        q.results = 1
        q
      end
      it { is_expected.to be_nil }
    end

    context 'given both query.start and query.results' do
      let(:query) do
        q = Textvid::Query.new
        q.start = 1
        q.results = 2
        q
      end
      it { expect(subject.start).to eq 3 }
      it { expect(subject.results).to eq 2 }
    end
  end
end