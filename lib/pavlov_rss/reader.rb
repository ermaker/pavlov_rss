require 'open-uri'
require 'nokogiri'
require 'active_support/core_ext'

module PavlovRss
  class Reader
    def opener &opener
      @opener = opener
    end

    def fetch
      hash_to_item(rss_to_hash(Nokogiri.XML(@opener.call)))
    end

    def check
      now = fetch
      @prev ||= now
      result = now - @prev
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
  end
end
