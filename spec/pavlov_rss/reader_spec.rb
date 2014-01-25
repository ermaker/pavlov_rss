require File.dirname(__FILE__) + '/../spec_helper'

describe PavlovRss::Reader do
	before :each do
		feed = RecursiveOpenStruct.new({channel: {title: "ChannelTitle"}})
		RSS::Parser.should_receive(:parse).with(anything).and_return(feed)
		@reader = PavlovRss::Reader.new("http://github.com/jakkdu/pavlov_rss") 	
	end

	describe "#fetch" do
		before :each do 
			@feeds = @reader.fetch
		end
		it "return right channel title" do
			@feeds.first.channel.title.should eq "ChannelTitle"
		end
	end
end
