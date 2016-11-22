require 'textvid/parser'

RSpec.describe Textvid::Parser do
  describe '#parse' do
    subject { Textvid::Parser.new.parse(input) }

    context 'given block elements' do
      context 'hn' do
        let(:input) { <<INPUT }
# h1
## h2
### h3

#### h4
##### h5
###### h6
INPUT
        it { is_expected.to eq <<EXPECTED }
<h1>h1</h1>
<h2>h2</h2>
<h3>h3</h3>
<h4>h4</h4>
<h5>h5</h5>
<h6>h6</h6>
EXPECTED
      end

      context 'paragraph' do
        let(:input) { <<INPUT }
hello, world
   bye, world
hellobye, world
INPUT
        it { is_expected.to eq <<EXPECTED }
<p>
hello, world
bye, world
hellobye, world
</p>
EXPECTED
      end

      context 'unordered list' do
        let(:input) { <<INPUT }
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
        it { is_expected.to eq <<EXPECTED }
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
      end

      context 'ordered list' do
        let(:input) { <<INPUT }
1. hello
2. world

1. hello
2. world
INPUT
        it { is_expected.to eq <<EXPECTED }
<ol>
<li>hello</li>
<li>world</li>
</ol>
<ol>
<li>hello</li>
<li>world</li>
</ol>
EXPECTED
      end

      context 'code' do
        let(:input) { <<INPUT }
    hello
    world

    hello, world
INPUT
        it { is_expected.to eq <<EXPECTED }
<pre><code>hello
world</code></pre>
<pre><code>hello, world</code></pre>
EXPECTED
      end
    end

    context 'given inline elements' do
      context 'escape' do
        let(:input) { 'hello & world' }
        it { is_expected.to eq <<EXPECTED }
<p>
hello &amp; world
</p>
EXPECTED
      end

      context 'emphasis' do
        let(:input) { 'hello, *world*!' }
        it { is_expected.to eq <<EXPECTED }
<p>
hello, <em>world</em>!
</p>
EXPECTED
      end

      context 'strong' do
        let(:input) { 'hello, **world**!' }
        it { is_expected.to eq <<EXPECTED }
<p>
hello, <strong>world</strong>!
</p>
EXPECTED
      end

      context 'code' do
        let(:input) { 'hello, `world`!' }
        it { is_expected.to eq <<EXPECTED }
<p>
hello, <pre><code>world</code></pre>!
</p>
EXPECTED
      end

      context 'link' do
        let(:input) { 'url: [hello, world](http://hello-world/)' }
        it { is_expected.to eq <<EXPECTED }
<p>
url: <a href="http://hello-world/">hello, world</a>
</p>
EXPECTED
      end

      context 'image' do
        let(:input) { 'image: ![Image](http://hello-world/image.jpg)' }
        it { is_expected.to eq <<EXPECTED }
<p>
image: <img alt="Image" src="http://hello-world/image.jpg">
</p>
EXPECTED
      end
    end
  end
end