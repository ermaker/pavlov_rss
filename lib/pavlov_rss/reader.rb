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
  end
end
