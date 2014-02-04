require 'pavlov_rss'
require 'rss'

class RSS::Rss::Channel
  def eql? other
    # only check required elements
    @title == other.title \
      and @description == other.description \
      and @link == other.link
  end
end

class RSS::Rss::Channel::Item
  def eql? other
    @title == other.title \
      and @description == other.description \
      and @link == other.link
  end
end

class RSS::Rss
  def eql? other
    @channel.eql? other.channel \
      and items.eql? other.items
  end
end
