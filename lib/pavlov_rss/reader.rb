require 'open-uri'
require 'nokogiri'
require 'active_support/core_ext'

module PavlovRss
  class Reader
    def initialize(url_or_lambda)
      @lambda =
        case url_or_lambda
        when String
          lambda {open(url_or_lambda, &:read)}
        else
          url_or_lambda
        end
    end

    def check
      now = Nokogiri.XML(@lambda.call)
      @prev ||= now
      result = new_items @prev, now
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
