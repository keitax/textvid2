module Textvid
  class Query
    attr_accessor :words, :label, :start, :results, :year, :month, :url_title

    def previous
      return nil unless @start && @results
      q = self.dup
      q.start = [1, @start - @results].max
      q.results = @start - q.start
      q
    end

    def next
      return nil unless @start && @results
      q = self.dup
      q.start += @results
      q
    end
  end
end
