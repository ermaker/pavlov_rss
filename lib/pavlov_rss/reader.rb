require 'rss'
require 'open-uri'
require 'nokogiri'
require 'active_support/core_ext'

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
      now = @urls.map {|url| Nokogiri.XML(open(url,&:read))}
      @prev ||= now
      result = @prev.zip(now).map do |p,n|
        new_items p, n
      end
      @prev = now
      return result
    end

    def item_to_json rss
      result = Hash.from_xml(rss.to_xml)['rss']['channel']['item'] || []
      return result if result.is_a? Array
      return [result]
    end

    def new_items lhs, rhs
      item_to_json(rhs) - item_to_json(lhs)
    end
  end
end
