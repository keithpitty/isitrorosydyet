require 'rubygems'
require 'sinatra'
require 'haml'
require 'activesupport'
require 'open-uri'

helpers do

end

class Meetup
  
  attr_reader :meetup_date, :cutoff_time, :days_until_next, :faces_url, :details_on_faces
  
  def initialize
    @meetup_date = derive_meetup_date
    @cutoff_time = Time.utc(@meetup_date.year, @meetup_date.month, @meetup_date.day, 15, 0, 0)
    @days_until_next = ((@cutoff_time - Time.now.utc) / (60 * 60 * 24)).to_i
    @faces_url = "http://faces.rubyoceania.org/groups/sydney/meetings/#{@meetup_date.strftime("%Y-%m-%d")}"
    @details_on_faces = are_meeting_details_on_faces?(@faces_url)
  end
  
  def details_on_faces?
    @details_on_faces
  end
  
  def needs_more_talks?
    !details_on_faces?
  end
  
  def recently_finished?
    days_until_next > 26
  end
  
  def on_today?
    days_until_next == 0
  end
  
  private
  def derive_meetup_date(year = Date.today.year, month = Date.today.month)
    first_day_of_month = Date.new(year, month, 1)
    # Meetings are held on the second Tuesday of the month
    case first_day_of_month.wday
    when 0
      meetup_date = Date.new(year, month, 10)
    when 1
      meetup_date = Date.new(year, month, 9)
    when 2
      meetup_date = Date.new(year, month, 8)
    when 3
      meetup_date = Date.new(year, month, 14)
    when 4
      meetup_date = Date.new(year, month, 13)
    when 5
      meetup_date = Date.new(year, month, 12)
    when 6
      meetup_date = Date.new(year, month, 11)
    end
    if meetup_date < Date.today
      if month == 12
        meetup_date = derive_meetup_date(year + 1, 1)
      else
        meetup_date = derive_meetup_date(year, month + 1)
      end
    end
    meetup_date
  end
  
  def are_meeting_details_on_faces?(url)
    details_on_faces = true
    begin
      open(url) {|f| f.read }
    rescue OpenURI::HTTPError => e
      details_on_faces = false
    end
    details_on_faces
  end
end

get "/" do
  @meetup = Meetup.new
  days = @meetup.days_until_next
  meetup_date = @meetup.meetup_date
  if @meetup.on_today?
    @big = 'YES'
    @small = '#rorosyd is on today!'
  else  
    @big = 'NO'
    if @meetup.recently_finished?
      @small = '#rorosyd is over for another month :('
    else
        @big = 'NO'
        trinity_map_link = "<a href='http://maps.google.com.au/maps?f=q&source=s_q&hl=en&geocode=&q=trinity+bar+surry+hills&vps=1&jsv=165c&sll=-25.335448,135.745076&sspn=40.257673,71.894531&num=10&iwloc=A'>the Trinity</a>"
        @small = "Only #{days} sleep#{days > 1 ? 's' : ''} to go... see you at #{trinity_map_link} on #{meetup_date.strftime("%A, #{meetup_date.to_date.day.ordinalize} %B")}"
    end
  end
  @plug = 'a <a href="http://bivou.ac">bivou.ac</a> service'
  haml :index, :format => :html5, :attr_wrapper => '"'
end