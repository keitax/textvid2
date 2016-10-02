require 'minitest/autorun'

require 'textvid/parser'

class ParserTest < Minitest::Test
  include Textvid

  def test_parse_headline
    input = <<INPUT
# h1
## h2
### h3

#### h4
##### h5
###### h6
INPUT
    expected = <<EXPECTED
<h1>h1</h1>
<h2>h2</h2>
<h3>h3</h3>
<h4>h4</h4>
<h5>h5</h5>
<h6>h6</h6>
EXPECTED
    assert_equal(expected, Parser.parse(input))
  end

  def test_parse_paragraph
    input = <<INPUT
hello, world
   bye, world
hellobye, world
INPUT
    expected = <<EXPECTED
<p>
hello, world
bye, world
hellobye, world
</p>
EXPECTED

    assert_equal(expected, Parser.parse(input))
  end

  def test_items
    input = <<INPUT
- 1
- 2
- 3

  - 1
  - 2
  - 3

-1
-2
-3
INPUT
    expected = <<EXPECTED
<ul>
<li>1</li>
<li>2</li>
<li>3</li>
</ul>
<ul>
<li>1</li>
<li>2</li>
<li>3</li>
</ul>
<p>
-1
-2
-3
</p>
EXPECTED
    assert_equal(expected, Parser.parse(input))
  end

  def test_ordered_items
    input = <<INPUT
1. hello
2. world

  1. hello
  2. world
INPUT
    expected = <<EXPECTED
<ol>
<li>hello</li>
<li>world</li>
</ol>
<ol>
<li>hello</li>
<li>world</li>
</ol>
EXPECTED
    assert_equal(expected, Parser.parse(input))
  end

  def test_parse_code
    input = <<INPUT
    hello
    world

    hello, world
INPUT
    expected = <<EXPECTED
<pre><code>hello
world</code></pre>
<pre><code>hello, world</code></pre>
EXPECTED
    assert_equal(expected, Parser.parse(input))
  end

  def test_escape
    input = 'hello & world'
    expected = <<EXPECTED
<p>
hello &amp; world
</p>
EXPECTED
  end

  def test_inline_em
    input = 'hello, *world*!'
    expected = <<EXPECTED
<p>
hello, <em>world</em>!
</p>
EXPECTED
    assert_equal(expected, Parser.parse(input))
  end

  def test_inline_strong
    input = 'hello, **world**!'
    expected = <<EXPECTED
<p>
hello, <strong>world</strong>!
</p>
EXPECTED
    assert_equal(expected, Parser.parse(input))
  end

  def test_inline_code
    input = 'hello, `world`!'
    expected = <<EXPECTED
<p>
hello, <pre><code>world</code></pre>!
</p>
EXPECTED
    assert_equal(expected, Parser.parse(input))
  end

  def test_inline_link
    input = 'url: [hello, world](http://hello-world/)'
    expected = <<EXPECTED
<p>
url: <a href="http://hello-world/">hello, world</a>
</p>
EXPECTED
    assert_equal(expected, Parser.parse(input))
  end

  def test_inline_image
    input = 'image: ![Image](http://hello-world/image.jpg)'
    expected = <<EXPECTED
<p>
image: <img alt="Image" src="http://hello-world/image.jpg">
</p>
EXPECTED
    assert_equal(expected, Parser.parse(input))
  end
end
