module Suprdate
  
  BASE_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  LIB_DIR = File.join(BASE_DIR,"lib").freeze
  
  require LIB_DIR + "/suprdate/day"
  require LIB_DIR + "/suprdate/month"
  require LIB_DIR + "/suprdate/year"
  require LIB_DIR + "/suprdate/occurrence_spec"

  WEEKDAYS_SYM_TO_I = {
    :mon => 1, :tue => 2, :wed => 3, :thu => 4, 
    :fri => 5, :sat => 6, :sun => 7
  }

  WEEKDAYS_I_TO_SYM = [
    nil, :sun, :mon, :tue, :wed, :thu, :fri, :sat
  ]

  WEEKDAYS_I_TO_STRING = [
    nil, 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ]

  MONTH_SYM_TO_I = {
    :jan => 1,    :feb => 2,    :mar => 3,
    :apr => 4,    :may => 5,    :jun => 6,
    :jul => 7,    :aug => 8,    :sep => 9,
    :oct => 10,   :nov => 11,   :dec => 12,
  }

  MONTH_I_TO_SYM = [
    nil, :jan, :feb, :mar, :apr, :may, :jun, :jul,
    :aug, :sep, :oct, :nov, :dec
  ]

  MONTH_I_TO_STRING = [
    nil, 'January', 'February', 'March', 'April', 
    'May', 'June', 'July', 'August', 'September', 
    'October', 'November', 'December'
  ]

  NUM_MONTHS_IN_YEAR = 12
  MONTH_RANGE = 1..NUM_MONTHS_IN_YEAR
  NUM_DAYS_IN_MONTHS = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  OCCURANCES = [nil, :first, :second, :third, :forth, :fifth]
  OCCURANCES_SYM_TO_I = {
    :first => 1, :second  => 2, :third  => 3, :forth => 4, :fifth => 5,
    :sixth => 6, :seventh => 7, :eighth => 8, :ninth => 9, :tenth => 10
  }
  WEEKDAY_RANGE = 1..7

  # for creating date objects such as year, months and days
  class Builder
  
    attr_accessor :day_factory, :month_factory, :week_definition
  
    def initialize
      @day_factory = Day
      @month_factory = Month
    end
  
    def year(value)
      y = Year.new(value)
      y.day_factory = @day_factory
      y.month_factory = @month_factory
      y
    end
  
    def month(year_value, month_value)
      m = @month_factory.new(year(year_value), month_value)
      m.day_factory = @day_factory
      m
    end
  
    def day(year_value, month_value, day_value)
      @day_factory.new(month(year(year_value), month_value), day_value)
    end
  
    def today
      time = Time.now
      day(time.year, time.month, time.day)
    end
    
    # returns the names of the methods that actually build stuff
    def self.building_methods
      (instance_methods - superclass.instance_methods).reject { |name| name =~ /_/ }
    end
  
  end

  DEFAULT_BUILDER = Builder.new

  # defines the important methods of DEFAULT_BUILDER as stand alone module methods
  Builder.building_methods.each do |name| 
    define_method(name.capitalize) { |*args| DEFAULT_BUILDER.send(name, *args) }
  end

  # disposes of the array that wraps a single element returns array otherwise
  def disarray(array) array.size == 1 ? array[0] : array end

  # filters elements from lists at specified frequency
  # freq may be specified as an integer or symbol
  def every(freq, enum, &block)
    freq = OCCURANCES_SYM_TO_I[freq] if freq.kind_of?(Symbol)
    out = if block
      enum
    else
      block = lambda { |value| out << value } 
      []
    end
    enum.each_with_index do |value, key|
      block.call(value) if key % freq == 0
    end
    out
  end
  
  module Inf
    def self.method_missing(*args) self end
  end
  
end
