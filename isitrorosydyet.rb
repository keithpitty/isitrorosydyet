require 'rubygems'
require 'sinatra'
require 'haml'
require 'activesupport'

helpers do
  def days_until_meetup
    now = Time.now.utc
    @meetup = Time.utc(2009, 6, 9, 15, 0, 0)
    ((@meetup - now) / (60 * 60 * 24)).to_i
  end
end

get "/" do
  @days = days_until_meetup
  case
  when @days > 0
    @big = 'NO'
    @small = "only #{@days} sleep#{@days > 1 ? 's' : ''} to go... see you at the Trinity on #{@meetup.strftime("%A, #{@meetup.to_date.day.ordinalize} %B")}"
  when @days == 0
    @big = 'YES'
    @small = '#rorosyd is on today!'
  else
    @big = 'NO'
    @small = '#rorosyd is over for another month :('
  end
  haml :index
end