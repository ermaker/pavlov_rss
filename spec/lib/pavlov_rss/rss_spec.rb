require 'spec_helper'
require 'pavlov_rss'

describe RSS::Rss do
  before :each do
    @rss = RSS::Parser.parse feed('rss1.xml')
  end

  describe "#eql?" do
    it "returns true with same object" do
      @rss.should eql @rss
    end

    it "returns true with different object but same content" do
      @rss.should eql @rss.dup
    end

    it "returns false with different channel" do
      ['channel_title.xml',
       'channel_link.xml',
       'channel_description.xml'].each do |fn|
         @other_rss = RSS::Parser.parse feed(fn)

         @rss.should_not eql @other_rss
       end
    end

    it "returns false with different items" do
      ['item_title.xml',
       'item_link.xml',
       'item_description.xml'].each do |fn|
         @other_rss = RSS::Parser.parse feed(fn)

         @rss.should_not eql @other_rss
       end
    end
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

describe RSS::Rss::Channel::Item do
  context '#eql?' do
    it 'returns true if same' do
      item1, = RSS::Parser.parse(feed('rss1.xml')).items
      item2, = RSS::Parser.parse(feed('rss1.xml')).items
      item1.should be_eql item2
    end

    it 'returns false if not same' do
      item1, item2= RSS::Parser.parse(feed('rss2.xml')).items
      item1.should_not be_eql item2
    end
  end

  context '#hash' do
    it 'returns true if same' do
      item1, = RSS::Parser.parse(feed('rss1.xml')).items
      item2, = RSS::Parser.parse(feed('rss1.xml')).items
      item1.should be_eql item2
      item1.hash.should == item2.hash
    end

    it 'returns false if not same' do
      item1, item2= RSS::Parser.parse(feed('rss2.xml')).items
      item1.hash.should_not == item2.hash
    end
  end

  context '#- with arrays' do
    it 'works' do
      items1= RSS::Parser.parse(feed('rss1.xml')).items
      items2= RSS::Parser.parse(feed('rss2.xml')).items
      result = items2 - items1
      result.should have(1).items
      result[0].core_value.should == ["title2", "description2", "http://example.com/title2"]
    end
  end
end

describe RSS::Rss::Channel do
  context '#eql?' do
    it 'returns true if same' do
      channel1 = RSS::Parser.parse(feed('rss1.xml')).channel
      channel2 = RSS::Parser.parse(feed('rss1.xml')).channel
      channel1.should be_eql channel2
    end

    it 'returns false if not same' do
      channel1 = RSS::Parser.parse(feed('rss1.xml')).channel
      channel2 = RSS::Parser.parse(feed('channel_title.xml')).channel
      channel1.should_not be_eql channel2
    end
  end

  context '#hash' do
    it 'returns true if same' do
      channel1 = RSS::Parser.parse(feed('rss1.xml')).channel
      channel2 = RSS::Parser.parse(feed('rss1.xml')).channel
      channel1.hash.should == channel2.hash
    end

    it 'returns false if not same' do
      channel1 = RSS::Parser.parse(feed('rss1.xml')).channel
      channel2 = RSS::Parser.parse(feed('channel_title.xml')).channel
      channel1.hash.should_not == channel2.hash
    end
  end
end

describe RSS::Rss do
  context '#-' do
    rss1 = RSS::Parser.parse feed('rss1.xml')
    rss2 = RSS::Parser.parse feed('rss2.xml')
    diff = rss2 - rss1
    diff.map(&:core_value).should == [["title2", "description2", "http://example.com/title2"]]
  end
end
