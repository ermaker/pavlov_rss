require 'spec_helper'
require 'pavlov_rss'
require 'fake_web'

describe PavlovRss::Reader do
  after do
    FakeWeb.clean_registry
  end

	describe "#fetch" do
		before :each do 
      FakeWeb.register_uri(:get, "http://example.com/test1", :body => sample_feed)
      @reader = PavlovRss::Reader.new("http://example.com/test1") 	
			@feeds = @reader.fetch
		end

		it "return right channel title" do
			@feeds.first.channel.title.should eq RSS::Parser.parse(sample_feed).channel.title
		end
	end

  describe "#check" do
    it "returns [] at first time" do
      FakeWeb.register_uri(:get, "http://example.com/rss.xml", body: sample_feed)
      @reader = PavlovRss::Reader.new("http://example.com/rss.xml")
			@reader.check.should be_empty
    end

    it "returns [] without changes" do
      FakeWeb.register_uri(:get, "http://example.com/rss.xml", body: sample_feed)
      @reader = PavlovRss::Reader.new("http://example.com/rss.xml")
			@reader.check
			@reader.check.should be_empty
    end
  end
end
