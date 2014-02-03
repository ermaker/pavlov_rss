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
