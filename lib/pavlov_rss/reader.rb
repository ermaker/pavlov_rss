require 'open-uri'
require 'nokogiri'
require 'active_support/core_ext'

module PavlovRss
  class Reader
    def initialize(urls_or_lambdas)
      @lambdas = Array(urls_or_lambdas).map do |url_or_lambda|
        case url_or_lambda
        when String
          lambda {open(url_or_lambda, &:read)}
        else
          url_or_lambda
        end
      end

      @feeds = []
    end

    def fetch(options = {})
      @lambdas.map(&:call).each do |rss|
        @feeds <<  RSS::Parser.parse(rss)
      end
    end

    def check
      now = @lambdas.map(&:call).map(&Nokogiri.method(:XML))
      @prev ||= now
      result = @prev.zip(now).map do |p,n|
        new_items p, n
      end
      @prev = now
      return result
    end

    def item_to_json rss
      value = Hash.from_xml(rss.to_xml)
      result = case
               when value.has_key?('rss')
                 value['rss']['channel']['item']
               when value.has_key?('feed')
                 value['feed']['entry']
               end
      result ||= []
      return result if result.is_a? Array
      return [result]
    end

    def new_items lhs, rhs
      item_to_json(rhs) - item_to_json(lhs)
    end
  end
end
