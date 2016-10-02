require 'erb'

module Textvid
  class Parser
    def self.parse(body)
      Parser.new.parse(body)
    end

    def initialize
      @lines = []
      @pos = 0
      @buf = StringIO.new
    end

    HN_RE = /^(\#+) *(.+)$/
    UL_ITEM_RE = /^( *)[\-\+\*] +(.+)$/
    OL_ITEM_RE = /^( *)\d+\. +(.+)$/
    BLANK_RE = /^\s*$/
    CODE_RE = /^ {4}(.+)$/

    def parse(body)
      @lines = body.lines
      while peek
        case peek
        when HN_RE
          level = peek.slice(HN_RE, 1).length
          body = peek.slice(HN_RE, 2)
          out_ln("<h#{level}>#{inline(body)}</h#{level}>")
          inc
        when UL_ITEM_RE
          out_ln('<ul>')
          while peek && UL_ITEM_RE =~ peek
            body = peek.slice(UL_ITEM_RE, 2)
            out_ln("<li>#{inline(body)}</li>")
            inc
          end
          out_ln('</ul>')
        when OL_ITEM_RE
          out_ln('<ol>')
          while peek && OL_ITEM_RE =~ peek
            body = peek.slice(OL_ITEM_RE, 2)
            out_ln("<li>#{inline(body)}</li>")
            inc
          end
          out_ln('</ol>')
        when CODE_RE
          out('<pre><code>')
          buf = []
          while peek && CODE_RE =~ peek
            body = peek.slice(CODE_RE, 1)
            buf.push(body)
            inc
          end
          out(ERB::Util.h(buf.join("\n")))
          out_ln('</code></pre>')
        when BLANK_RE
          inc
        else
          out_ln('<p>')
          while peek && p_line?(peek)
            out_ln(inline(peek.strip))
            inc
          end
          out_ln('</p>')
        end
      end
      @buf.rewind
      @buf.read
    end

    private

    EMPHASIS_RE = /\*(.+?)\*/
    STRONG_RE = /\*\*(.+?)\*\*/
    INLINE_CODE_RE = /`(.+?)`/
    LINK_RE = /\[(.+?)\]\((.+?)\)/
    IMAGE_RE = /!\[(.+?)\]\((.+?)\)/

    def inline(text)
      t = ERB::Util.h(text)
      t = t.gsub(STRONG_RE, '<strong>\1</strong>')
      t = t.gsub(EMPHASIS_RE, '<em>\1</em>')
      t = t.gsub(INLINE_CODE_RE, '<pre><code>\1</code></pre>')
      t = t.gsub(IMAGE_RE, '<img alt="\1" src="\2">')
      t = t.gsub(LINK_RE, '<a href="\2">\1</a>')
      t
    end

    def p_line?(line)
      [
          HN_RE,
          UL_ITEM_RE,
          OL_ITEM_RE,
          BLANK_RE,
          CODE_RE
      ].all? { |re|
        re !~ line
      }
    end

    def peek
      @lines[@pos]
    end

    def out(text)
      @buf.write(text)
    end

    def out_ln(line)
      @buf.write(line)
      @buf.write("\n")
    end

    def inc
      @pos += 1
    end
  end
end
