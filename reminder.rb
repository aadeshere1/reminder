#!/usr/bin/env ruby
require 'date'
require 'time'
require 'google/apis/calendar_v3'
require 'googleauth'
require 'ap'

class Reminder
  attr_reader :date, :time, :message
  def initialize(date, time, message)
    @date = date
    @time = time
    @message = message
  end

  def self.call(date, time, message)
    Reminder.new(date, time, message).create_reminder_on_gcal
  end

  def create_reminder_on_gcal
    begin
      date = Date.strptime(@date, "%Y-%m-%d")
    rescue StandardError => e
      show_message_and_exit
    else
      year = date.year
      month = date.month
      day = date.day
    end

    begin
      time = Time.parse(@time)
    rescue StandardError => e
      show_message_and_exit
    else
      hour = time.hour
      min = time.min
    end
    
    start = DateTime.new(year, month, day, hour, min,0,Time.now.zone)
    end_in_min = hour*60 + min + 30
    end_hour = end_in_min / 60
    end_min = end_in_min % 60
    end_time = DateTime.new(year, month, day, end_hour, end_min)

    event = {start_time: start, end_time: end_time, summary: @message}
    add_event_to_calendar(plug, event)
  end

  private

  def plug
    service = Google::Apis::CalendarV3::CalendarService.new
    service.client_options.application_name = "millimeter-staging"
    service.authorization = authorize
    service
  end

  def authorize
    # Rails.root.join('config', 'client-staging.json')
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open((ENV['GCP_CONFIG_PATH']).to_s),
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR
    )
    authorizer.fetch_access_token!
    authorizer
  end

  def show_message_and_exit
    puts "Please enter valid date, time and message"
    puts "Default event duration is set to 30 minutes"
    puts "Example:\n reminder '2019-01-01' '2:13PM' 'Setup PC for my mother because I am a developer but for family I am just a guy who repairs electronics.'"
    exit  
  end

  def add_event_to_calendar(service, event)
    begin
      new_event = Google::Apis::CalendarV3::Event.new(
        summary: event[:summary],
        start: { date_time: event[:start_time].rfc3339 },
        end: { date_time: event[:end_time].rfc3339 }
        )
      res = service.insert_event("your-email@gmail.com", new_event)
    rescue Google::Apis::ClientError => e
      puts "Check if your email is correct or not"
    else
      if res.status == "confirmed"
        ap "Event has been registered successfully on calendar #{res.organizer.display_name}"
      else
        puts "the hell i know"
      end
    end
  end
end


# add_reminder(ARGV[0], ARGV[1], ARGV[2])

Reminder.call(ARGV[0], ARGV[1], ARGV[2])