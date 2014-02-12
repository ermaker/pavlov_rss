require 'spec_helper'
require 'pavlov_rss'
require 'nokogiri'
require 'fake_web'

describe PavlovRss::Reader do
  after do
    FakeWeb.clean_registry
  end

  describe "#fetch" do
    before :each do
      @url = "http://example.com/test1"
      FakeWeb.register_uri(:get, @url, :body => sample_feed)
      @reader = PavlovRss::Reader.new @url
      @feeds = @reader.fetch
    end

    it "return right channel title" do
      expected_title = RSS::Parser.parse(sample_feed).channel.title
      @feeds.first.channel.title.should eq expected_title
    end
  end

  context "with an example reader" do
    before do
      @url = "http://example.com/rss.xml"
      @reader = PavlovRss::Reader.new @url
    end

    describe "#check" do
      context "with static rss" do
        before do
          FakeWeb.register_uri(:get, @url, body: feed('rss1.xml'))
        end

        it "returns [[]] at first time" do
          @reader.check.should == [[]]
        end

        it "returns [[]] without changes" do
          @reader.check
          @reader.check.should == [[]]
        end
      end

      it "does not return [[]] with any chagnes" do
        FakeWeb.register_uri(:get, @url, [
                             {body: feed('rss1.xml')},
                             {body: feed('rss2.xml')},
        ])
        @reader.check
        @reader.check.should_not == [[]]
      end

      it "returns new items" do
        FakeWeb.register_uri(:get, @url, [
                             {body: feed('rss1.xml')},
                             {body: feed('rss2.xml')},
                             {body: feed('rss3.xml')},
                             {body: feed('rss4.xml')},
                             {body: feed('rss5.xml')},
        ])
        @reader.check
        @reader.check.map{|r|r.map(&:to_xml)}.should == [[<<-EOXML.chomp]]
<item>
      <title>title2</title>
      <link>http://example.com/title2</link>
      <description>description2</description>
    </item>
        EOXML
        @reader.check.map{|r|r.map(&:to_xml)}.should == [[<<-EOXML.chomp]]
<item>
      <title>title3</title>
      <link>http://example.com/title3</link>
      <description>description3</description>
    </item>
        EOXML
        @reader.check.map{|r|r.map(&:to_xml)}.should == [[<<-EOXML.chomp]]
<item>
      <title>title4</title>
      <link>http://example.com/title4</link>
      <description>description4</description>
    </item>
        EOXML
        @reader.check.map{|r|r.map(&:to_xml)}.should == [[<<-EOXML.chomp]]
<item>
      <title>title5</title>
      <link>http://example.com/title5</link>
      <description>description5</description>
    </item>
        EOXML
      end
    end

    describe "#new_items" do
      it "returns empty with same rss" do
        rss1 = Nokogiri.XML(feed('rss1.xml'))
        rss2 = Nokogiri.XML(feed('rss1.xml'))
        items = @reader.new_items rss1, rss2
        items.should == []
      end

      it "returns empty with not same rss" do
        rss1 = Nokogiri.XML(feed('rss1.xml'))
        rss2 = Nokogiri.XML(feed('rss2.xml'))
        #items = @reader.new_items rss1, rss2

        lhs = rss1
        rhs = rss2
        path = '/rss/channel/item'
        litems = lhs.xpath(path)
        ritems = rhs.xpath(path)

        litems.should have(1).item
        ritems.should have(2).items

        litems_xml = litems.map(&:to_xml)
        items = ritems.reject do |item|
          litems_xml.include? item.to_xml
        end

        items.map(&:to_xml).should == [<<-EOXML.chomp]
<item>
      <title>title2</title>
      <link>http://example.com/title2</link>
      <description>description2</description>
    </item>
        EOXML
      end
    end
  end
end
