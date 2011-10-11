require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra'
require 'haml'
require 'net/http'
require 'uri'
require 'pp'

class AskCraig < Sinatra::Base
  get '/rss' do

    s = get_html_content("http://newyork.craigslist.org/search/aap/fct?query=train")
    @answers = Array.new

    s.scan(/<p>(<a href="(.*?)"\>(.*?))<\/p>/).each do |m|
      @answers << {:link => m[1], :title => m.shift.gsub(/<.*?>/, '')}
    end

    content_type 'application/rss+xml'
    haml(:rss, :format => :xhtml, :escape_html => true, :layout => false)
  end

  def get_html_content(request_url)
    url = URI.parse(request_url)
    full_path = (url.query.empty?) ? url.path : "#{url.path}?#{url.query}"
      the_request = Net::HTTP::Get.new("http://newyork.craigslist.org/fct/aap/")

    the_response = Net::HTTP.start(url.host, url.port) { |http|
      http.request(the_request)
    }

    return the_response.body
  end

end

