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
	end
end
