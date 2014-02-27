require 'open-uri'
require 'nokogiri'
require 'active_support/core_ext'

module PavlovRss
  class Reader
    def initialize(url_or_lambda=nil)
      @opener =
        case url_or_lambda
        when String
          lambda {open(url_or_lambda, &:read)}
        else
          url_or_lambda
        end
    end

    def opener &opener
      @opener = opener
    end

    def check
      now = Nokogiri.XML(@opener.call)
      @prev ||= now
      result = new_items @prev, now
      @prev = now
      return result
    end

    def rss_to_hash rss
      Hash.from_xml(rss.to_xml)
    end

    def hash_to_item hash
      result = case
               when hash.has_key?('rss')
                 hash['rss']['channel']['item']
               when value.has_key?('feed')
                 hash['feed']['entry']
               end
      result ||= []
      return result if result.is_a? Array
      return [result]
    end

    def new_items lhs, rhs
      hash_to_item(rss_to_hash(rhs)) - hash_to_item(rss_to_hash(lhs))
    end
  end
end
