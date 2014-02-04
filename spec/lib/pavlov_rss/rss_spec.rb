require 'spec_helper'
require 'pavlov_rss'

describe RSS::Rss do
  before :each do
    @rss = RSS::Parser.parse feed('rss1.xml')
  end

  describe "Channel#eql?" do
    before :each do
      @channel = @rss.channel
    end

    it "returns true with same object" do
      @channel.should eql @channel
    end

    it "returns true with different object but same content" do
      @channel.should eql @channel.dup
    end

    it "returns false with different content" do
      ['channel_title.xml',
       'channel_link.xml',
       'channel_description.xml'].each do |fn|
          @other_rss = RSS::Parser.parse feed(fn)
          @other_channel = @other_rss.channel

          @channel.should_not eql @other_channel
      end
    end
  end

  describe "Item#eql?" do
    before :each do
      @items = @rss.items
    end

     it "returns true with same object" do
       @items.zip(@items) { |arr| arr[0].should eql arr[1] }
     end

     it "returns true with different object but same content" do
       @items.zip(@items.dup) { |arr| arr[0].should eql arr[1] }
     end

     it "returns false with different content" do
       ['item_title.xml',
        'item_link.xml',
        'item_description.xml'].each do |fn|
            @other_rss = RSS::Parser.parse feed(fn)
            @other_items = @other_rss.items

            @items.zip(@other_items) { |arr| arr[0].should_not eql arr[1] }
        end
     end

     it "returns true even if author is different" do
       @other_rss = RSS::Parser.parse feed('item_author.xml')
        @other_items = @other_rss.items

        @items.zip(@other_items) { |arr| arr[0].should eql arr[1] }
     end
  end
end
