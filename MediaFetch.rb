require 'cgi'
require 'json'
require 'net/http'

BASE_WIKI_URL = "https://wiki.netsoc.tcd.ie/"

def search(term)
	uri = URI.parse "#{BASE_WIKI_URL}api.php?action=opensearch&search=#{CGI.escape term}&limit=1&redirects=resolve&format=json"
	response = fetch uri
	json = JSON.parse! response.body
	if json["1"].length > 0
		get_title_message json["1"][0]
	else
		"Nothing found."
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

def get_title_message(title)
	url = "#{BASE_WIKI_URL}index.php?title=#{CGI.escape title}"
	summary = fetch("#{url}&action=raw").body.match /^([A-Za-z]+.*)/
	"\C-b#{title}\C-o#{summary.nil? ? "" : " - "} #{summary.nil? ? "" : summary[1].sub(/(?:\b.{1,3})?$/, "(…)")} - #{url}"
end
