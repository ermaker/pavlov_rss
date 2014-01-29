require 'spec_helper'
require 'pavlov_rss'
require 'fake_web'

describe PavlovRss::Reader do
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
end
