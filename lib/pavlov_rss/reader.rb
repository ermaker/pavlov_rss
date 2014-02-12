require 'rss'
require 'open-uri'

module PavlovRss
  class Reader
    def initialize(urls)
      @urls = Array(urls)
      @feeds = []
    end

    def fetch(options = {})
      @urls.each do |url|
        open(url) do |rss|
          @feeds <<  RSS::Parser.parse(rss)
        end
      end

      @feeds
    end

    def check
      now = @urls.map {|url| open(url,&:read)}
      @prev ||= now
      if @prev == now
        result = []
      else
        result = :TODO_NOT_IMPLEMENTED
      end
      @prev = now
      return result
    end

    def new_items lhs, rhs
      path = '/rss/channel/item'
      prev = lhs.xpath(path).map(&:to_xml)
      now = rhs.xpath(path).reject do |item|
        prev.include? item.to_xml
      end
      return now
    end
  end
end
