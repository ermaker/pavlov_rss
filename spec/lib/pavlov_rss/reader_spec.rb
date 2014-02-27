require 'spec_helper'
require 'pavlov_rss'
require 'nokogiri'
require 'fake_web'

describe PavlovRss::Reader do
  after do
    FakeWeb.clean_registry
  end

  context '#hash_to_item' do
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

    describe "#item_to_json" do
      it "works" do
        pending
        rss = Nokogiri.XML(feed('rss1.xml'))
        result = @reader.item_to_json rss
        result.should == [
          {
          "title"=>"title1",
          "link"=>"http://example.com/title1",
          "description"=>"description1"
        }]
      end
      it "works on 0-items rss" do
        pending
        rss = Nokogiri.XML(feed('rss0.xml'))
        result = @reader.item_to_json rss
        result.should == []
      end
      it "works on atom" do
        pending
        atom = Nokogiri.XML(feed('atom.xml'))
        result = @reader.item_to_json atom
        result.should == [{
          "title"=>"title",
          "id"=>"tag_string",
          "content"=>"content"
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
