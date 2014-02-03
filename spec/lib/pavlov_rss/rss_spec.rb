require 'spec_helper'
require 'pavlov_rss'

describe RSS::Rss::Channel do
  describe "#eql?" do
    before :each do
      @rss = RSS::Parser.parse feed('sample_feed.xml')
      @channel = @rss.channel
    end

    it "returns true with same object" do
      @channel.should eql @channel
    end

    it "returns true with different object but same content" do
      @channel.should eql @channel.dup
    end

    it "returns false with different content " do
      ['different_title.xml',
       'different_link.xml',
       'different_description.xml'].each do |fn|
        @other_rss = RSS::Parser.parse feed(fn)
        @other_channel = @other_rss.channel

        @channel.should_not eql @other_channel
      end
    end
  end
end
