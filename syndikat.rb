require 'rubygems'
require 'simple-rss'
require 'open-uri'
require 'config'
require 'cgi'


class Syndikat

  def initialize(feed_urls, output_file, css_file, title)
    @feed_urls, @output_file = feed_urls, output_file
    @css_file, @title = css_file, title
    @ready_items = []
  end


  def purr
    parse @feed_urls
    write_out
  end


  private

  def parse(feed_urls)
  
    @feed_urls.each do |url|
      @ready_items += SimpleRSS.parse(open(url).read).items
    end
  
    @ready_items.sort! {|x,y| y.pubDate <=> x.pubDate}  #spaceship operator

    self
  end


  def write_out

    # TODO: Extract to .erb file
    File.open(@output_file, 'w') do |f|  
      f.puts "<html>
        <head><link href=#{@css_file} type='text/css' rel='stylesheet'><title>#{@title}</title></head>
        <body>
          <div id ='container'><h1>#{@title}</h1>"
  		
      @ready_items.each do |item|

        # The feed from SimpleRSS contains escaped (ie. safe) HTML
        # So we convert it HTML and then strip out any markup
        plaintext_description = strip_html(CGI.unescapeHTML item.description)

        f.puts "<div class = 'feed_item'>"
        f.puts "<h2>Title: #{item.title}</h2>"
        #f.puts "<h2>By: #{item.author}</h2>" # Not working
        f.puts "<i>Link: <a href ='#{item.link}'> #{item.link} </a></i>"
        f.puts "<p class ='published'>Published: #{item.pubDate}</p>"
        f.puts "<p class='content'>#{plaintext_description}</p>"	
      end
  
      f.puts "</div></body></html>"

    end	# of File.open
  
  end # of method


  def strip_html(str)
    return '' if str.nil?
    str.gsub(/<\/?[^>]*>/, "")
  end

end
 
# Main function
syndikat = Syndikat.new(@@feed_list, @@output_file, @@css_file, @@title)
syndikat.purr # Now check your output file!
