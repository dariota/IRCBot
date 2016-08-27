require 'net/http'
require 'cgi'

def search(term)
	fetch_result CGI.escape term
end

def fetch_result(page)
	uri = URI.parse "https://wiki.netsoc.tcd.ie/index.php?search=#{page}&button=&title=Special%3ASearch"
	response = fetch uri

	title = get_title response
	title.nil? ? "None found." : "\C-b#{title}\C-o - #{response.uri}"
end

def get_title(response)
	match = /<title>(.*?) - Netsoc Wiki<\/title>/.match response.body
	unless match.nil? || (match[1].include? "Search results")
		puts match
		match[1]
	else
		searchMatch = response.body.match /'.*title="(.+?)"/
		unless searchMatch.nil?
			puts "Searching for #{searchMatch[1]}"
			fetch_result(searchMatch[1])
		else
			nil
		end
	end
end

def fetch(uri_str, limit = 10)
	return nil if limit == 0

	response = Net::HTTP.get_response URI uri_str

	case response
	when Net::HTTPSuccess then
		response
	when Net::HTTPRedirection then
		location = response['location']
		fetch location, limit - 1
	else
		response.value
	end
end
