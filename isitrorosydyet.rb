require 'rubygems'
require 'sinatra'
require 'haml'
require 'activesupport'

helpers do
  def days_until_meetup
    now = Time.now.utc
    @meetup = Time.utc(2009, 7, 14, 15, 0, 0)
    ((@meetup - now) / (60 * 60 * 24)).to_i
  end
end

get "/" do
  @days = days_until_meetup
  case
  when @days > 0
    @big = 'NO'
    @small = "only #{@days} sleep#{@days > 1 ? 's' : ''} to go... see you at the Trinity on #{@meetup.strftime("%A, #{@meetup.to_date.day.ordinalize} %B")}"
    @details = false
    @need_more_talks = true
  when @days == 0
    @big = 'YES'
    @small = '#rorosyd is on today!'
  else
    @big = 'NO'
    @small = '#rorosyd is over for another month :('
    @over = true
  end
  @plug = 'a <a href="http://bivou.ac">bivou.ac</a> service'
  haml :index, :options => {:format => :html5,
    :attr_wrapper => '"'}
end