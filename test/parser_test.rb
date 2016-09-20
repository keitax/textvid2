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
end
