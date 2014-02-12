require 'pavlov_rss'
require 'rss'

module HashEqlWithValues
  def hash
    core_value.hash
  end
  def eql? other
    # only check required elements
    core_value.eql? other.core_value
  end
end

class RSS::Rss::Channel
  include HashEqlWithValues
  def core_value
    [@title, @description, @link]
  end
end

class RSS::Rss::Channel::Item
  include HashEqlWithValues
  def core_value
    [@title, @description, @link]
  end
end

class RSS::Rss
  include HashEqlWithValues
  def core_value
    [@channel, items]
  end
  def - rhs
    items - rhs.items
  end
end
