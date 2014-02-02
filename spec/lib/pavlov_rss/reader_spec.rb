require 'spec_helper'
require 'pavlov_rss'
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

  describe "#check" do
    before do
      @url = "http://example.com/rss.xml"
      @reader = PavlovRss::Reader.new @url
    end

    context "with static rss" do
      before do
        FakeWeb.register_uri(:get, @url, body: feed('rss1.xml'))
      end

      it "returns [] at first time" do
        @reader.check.should be_empty
      end

      it "returns [] without changes" do
        @reader.check
        @reader.check.should be_empty
      end
    end

    it "returns not empty with any chagnes" do
      FakeWeb.register_uri(:get, @url, [
                           {body: feed('rss1.xml')},
                           {body: feed('rss2.xml')},
      ])
      @reader.check
      @reader.check.should_not be_empty
    end
  end
end
