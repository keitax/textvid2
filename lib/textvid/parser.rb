module Textvid
  class Parser
    def self.parse(body)
      Parser.new.parse(body)
    end

    def initialize
      @lines = []
      @pos = 0
      @buf = []
    end

    HN_RE = /^(\#+) *(.+)$/
    UL_ITEM_RE = /^( *)[\-\+\*] +(.+)$/
    OL_ITEM_RE = /^( *)\d+\. +(.+)$/
    BLANK_RE = /^\s*$/

    def parse(body)
      @lines = body.lines.map(&:strip)
      while line = @lines[@pos]
        case line
        when HN_RE
          level = line.slice(HN_RE, 1).length
          body = line.slice(HN_RE, 2)
          @buf.push("<h#{level}>#{body}</h#{level}>")
          @pos += 1
        when UL_ITEM_RE
          @buf.push('<ul>')
          line = @lines[@pos]
          while line && UL_ITEM_RE =~ line
            body = line.slice(UL_ITEM_RE, 2)
            @buf.push("<li>#{body}</li>")
            @pos += 1
            line = @lines[@pos]
          end
          @buf.push('</ul>')
        when OL_ITEM_RE
          @buf.push('<ol>')
          line = @lines[@pos]
          while line && OL_ITEM_RE =~ line
            body = line.slice(OL_ITEM_RE, 2)
            @buf.push("<li>#{body}</li>")
            @pos += 1
            line = @lines[@pos]
          end
          @buf.push('</ol>')
        when BLANK_RE
          @pos += 1
        else
          @buf.push('<p>')
          line = @lines[@pos]
          while line && p_line?(line)
            @buf.push(line)
            @pos += 1
            line = @lines[@pos]
          end
          @buf.push('</p>')
        end
      end
      @buf.push('')
      @buf.join("\n")
    end

    private

    def p_line?(line)
      [
          HN_RE,
          UL_ITEM_RE,
          OL_ITEM_RE,
          BLANK_RE
      ].all? { |re|
        re !~ line
      }
    end
  end
end
