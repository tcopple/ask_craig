require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra'
require 'haml'
require 'net/http'
require 'uri'
require 'pp'

class AskCraig < Sinatra::Base
  get '/rss' do
    location = params[:location] || "newyork"
    city = params[:city] || "city"
    list = params[:list] || "aap"
    query = params[:query] || nil

    url = "http://#{location}.craigslist.org/"
    if query.nil?
      url << "#{city}/#{list}"
    else
      url << "search/#{list}/#{city}?query=#{query}"
    end

    s = get_html_content(url)
    @answers = Array.new

    if list == "aap"
      s.scan(/<p>(.*?)-.*?(<a href="(.*?)">(.*?)<\/a>).*?font.*?>(.*?)<\/font.*?<\/p>/).each do |m|
        @answers << { :date => m[0].strip, :link => m[2], :title => m[3].gsub(/<.*?>/, ''), :cost => 0, :location => m[4].strip }
      end
    else
      s.scan(/(.*?)-.*?(<a href="(.*?)">(.*?)<\/a>)\W*.*?font.*?>(.*?)<\/font.*?/).each do |m|
        @answers << { :date => m[0].strip, :link => m[2], :title => m[3].gsub(/<.*?>/, ''), :cost => m[4], :location => m[5].try(:strip) }
      end
    end

    content_type 'application/rss+xml'
    haml(:rss, :format => :xhtml, :escape_html => true, :layout => false)
  end

  def get_html_content(request_url)
    str = "curl #{request_url}"
    puts "Executing [#{str}]"

    ret = `#{str}`
    return ret
  end
end
