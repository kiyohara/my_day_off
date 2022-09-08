# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'date'

require_relative "my_day_off/version"

module MyDayOff
  class Error < StandardError; end

  JP_HOLIDAYS_API_EP='https://holidays-jp.github.io/api/v1/date.json'

  @@holidays = nil

  def self.load_holidays
    ret = {}

    begin
      uri = URI.parse(JP_HOLIDAYS_API_EP);
      api_ret = Net::HTTP.get(uri)
      ret = JSON.parse(api_ret)
    rescue => e
      STDERR.puts e
      # raise e
    end

    ret
  end

  def self.update_holidays
    return unless @@holidays.nil?

    @@holidays = self.load_holidays
  end

  def self.holiday?(date)
    self.update_holidays

    !@@holidays[date.strftime('%Y-%m-%d')].nil?
  end

  def self.dayoff?(date)
    date.sunday? || date.saturday? || self.holiday?(date)
  end

  def self.first_weekday_of_the_month(origin = Date.today)
    first_day_of_the_month = Date.new(origin.year(), origin.month(), 1)
    first_weekday_of_the_month = first_day_of_the_month

    while self.dayoff?(first_weekday_of_the_month)
      first_weekday_of_the_month += 1
    end

    first_weekday_of_the_month
  end

  def self.first_weekday_of_the_month?(date = Date.today)
    date == self.first_weekday_of_the_month(date)
  end

  def self.last_weekday_of_the_month(origin = Date.today)
    last_day_of_the_month = Date.new(origin.year(), origin.month(), -1)
    last_weekday_of_the_month = last_day_of_the_month

    while self.dayoff?(last_weekday_of_the_month)
      last_weekday_of_the_month -= 1
    end

    last_weekday_of_the_month
  end

  def self.last_weekday_of_the_month?(date = Date.today)
    date == self.last_weekday_of_the_month(date)
  end
end
