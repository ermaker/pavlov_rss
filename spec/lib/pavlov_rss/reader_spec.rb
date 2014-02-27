require 'spec_helper'
require 'pavlov_rss'
require 'nokogiri'
require 'fake_web'

describe PavlovRss::Reader do
  after do
    FakeWeb.clean_registry
  end

  describe '#hash_to_item' do
    it 'works' do
      empty = {'rss' => {'channel' => {'item' => []}}}
      one = {'rss' => {'channel' => {'item' => [
        {'title' => 'title1'},
      ]}}}
      two = {'rss' => {'channel' => {'item' => [
        {'title' => 'title1'},
        {'title' => 'title2'},
      ]}}}
      subject.hash_to_item(empty).should be_empty
      subject.hash_to_item(one).should have(1).item
      subject.hash_to_item(two).should have(2).items
    end
  end

  describe "#rss_to_hash" do
    it "works on general rss" do
      rss = Nokogiri.XML(feed('rss2.xml'))
      result = subject.rss_to_hash rss
      result.should == {"rss"=>{"version"=>"2.0", "channel"=>{"title"=>"title", "link"=>"http://example.com", "description"=>"description", "item"=>[{"title"=>"title2", "link"=>"http://example.com/title2", "description"=>"description2"}, {"title"=>"title1", "link"=>"http://example.com/title1", "description"=>"description1"}]}}}
    end

    it "works on 1-item rss" do
      rss = Nokogiri.XML(feed('rss1.xml'))
      result = subject.rss_to_hash rss
      result.should == {"rss" => {"version"=>"2.0", "channel"=>{"title"=>"title", "link"=>"http://example.com", "description"=>"description", "item"=>{"title"=>"title1", "link"=>"http://example.com/title1", "description"=>"description1"}}}}
    end

    it "works on 0-items rss" do
      rss = Nokogiri.XML(feed('rss0.xml'))
      result = subject.rss_to_hash rss
      result.should == {"rss" => {"version"=>"2.0", "channel"=>{"title"=>"title", "link"=>"http://example.com", "description"=>"description"}}}
    end

    it "works on atom" do
      atom = Nokogiri.XML(feed('atom.xml'))
      result = subject.rss_to_hash atom
      result.should == {"feed"=>{"xmlns"=>"http://www.w3.org/2005/Atom", "entry"=>{"title"=>"title", "id"=>"tag_string", "content"=>"content"}}}
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

        it "returns [] at first time" do
          @reader.check.should == []
        end

        it "returns [] without changes" do
          @reader.check
          @reader.check.should == []
        end
      end

      it "does not return [] with any chagnes" do
        FakeWeb.register_uri(:get, @url, [
                             {body: feed('rss1.xml')},
                             {body: feed('rss2.xml')},
        ])
        @reader.check
        @reader.check.should_not == []
      end

      it "returns new items" do
        FakeWeb.register_uri(:get, @url, [
                             {body: feed('rss0.xml')},
                             {body: feed('rss1.xml')},
                             {body: feed('rss2.xml')},
                             {body: feed('rss3.xml')},
                             {body: feed('rss4.xml')},
                             {body: feed('rss5.xml')},
        ])
        @reader.check
        @reader.check.should == [
          {
          "title"=>"title1",
          "link"=>"http://example.com/title1",
          "description"=>"description1"
        }]
        @reader.check.should == [
          {
          "title"=>"title2",
          "link"=>"http://example.com/title2",
          "description"=>"description2"
        }]
        @reader.check.should == [
          {
          "title"=>"title3",
          "link"=>"http://example.com/title3",
          "description"=>"description3"
        }]
        @reader.check.should == [
          {
          "title"=>"title4",
          "link"=>"http://example.com/title4",
          "description"=>"description4"
        }]
        @reader.check.should == [
          {
          "title"=>"title5",
          "link"=>"http://example.com/title5",
          "description"=>"description5"
        }]
        @reader.check.should == []
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
        items = @reader.new_items rss1, rss2

        items.should == [
          {
          "title"=>"title2",
          "link"=>"http://example.com/title2",
          "description"=>"description2"
        }]
      end
    end
  end

  context 'with a labmda' do
    before do
      @url = "http://example.com/rss.xml"
      @reader = PavlovRss::Reader.new lambda { open(@url, &:read) }
    end
    describe '#check' do
      it 'works' do
        FakeWeb.register_uri(:get, @url, [
                             {body: feed('rss0.xml')},
                             {body: feed('rss1.xml')},
                             {body: feed('rss2.xml')},
                             {body: feed('rss3.xml')},
                             {body: feed('rss4.xml')},
                             {body: feed('rss5.xml')},
        ])
        @reader.check
        @reader.check.should == [
          {
          "title"=>"title1",
          "link"=>"http://example.com/title1",
          "description"=>"description1"
        }]
        @reader.check.should == [
          {
          "title"=>"title2",
          "link"=>"http://example.com/title2",
          "description"=>"description2"
        }]
        @reader.check.should == [
          {
          "title"=>"title3",
          "link"=>"http://example.com/title3",
          "description"=>"description3"
        }]
        @reader.check.should == [
          {
          "title"=>"title4",
          "link"=>"http://example.com/title4",
          "description"=>"description4"
        }]
        @reader.check.should == [
          {
          "title"=>"title5",
          "link"=>"http://example.com/title5",
          "description"=>"description5"
        }]
        @reader.check.should == []
      end
    end
  end

  context 'with a labmda' do
    before do
      @url = "http://example.com/rss.xml"
      @reader = PavlovRss::Reader.new lambda { open(@url, &:read) }
    end
    describe '#check' do
      it 'works' do
        FakeWeb.register_uri(:get, @url, [
                             {body: feed('rss0.xml')},
                             {body: feed('rss1.xml')},
                             {body: feed('rss2.xml')},
                             {body: feed('rss3.xml')},
                             {body: feed('rss4.xml')},
                             {body: feed('rss5.xml')},
        ])
        @reader.check
        @reader.check.should == [
          {
          "title"=>"title1",
          "link"=>"http://example.com/title1",
          "description"=>"description1"
        }]
        @reader.check.should == [
          {
          "title"=>"title2",
          "link"=>"http://example.com/title2",
          "description"=>"description2"
        }]
        @reader.check.should == [
          {
          "title"=>"title3",
          "link"=>"http://example.com/title3",
          "description"=>"description3"
        }]
        @reader.check.should == [
          {
          "title"=>"title4",
          "link"=>"http://example.com/title4",
          "description"=>"description4"
        }]
        @reader.check.should == [
          {
          "title"=>"title5",
          "link"=>"http://example.com/title5",
          "description"=>"description5"
        }]
        @reader.check.should == []
      end
    end
  end
end
