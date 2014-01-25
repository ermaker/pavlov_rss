module PavlovRss
	class Reader
		def initialize(urls)
			@urls = Array(urls)
		end
		def fetch(options = {})
			Array(RSS::Parser.parse(1))
		end
	end
end
