module Suprdate
  
  # Creates date objects of classes such as Year, Month and Day.
  class Builder
  
    attr_accessor :day_factory, :month_factory
    
    def initialize
      @day_factory = Day
      @month_factory = Month
    end
  
    # Creates an instance of Suprdate::Year.
    def year(value)
      y = Year.new(value)
      y.day_factory = @day_factory
      y.month_factory = @month_factory
      y
    end
  
    # Creates an instance of Suprdate::Month.
    def month(year_value, month_value)
      m = @month_factory.new(year(year_value), month_value)
      m.day_factory = @day_factory
      m
    end
  
    # Creates an instance of Suprdate::Day.
    def day(year_value, month_value, day_value)
      @day_factory.new(month(year_value, month_value), day_value)
    end
  
    # An instance of Suprdate::Day representing the current day.
    def today
      time = Time.now
      day(time.year, time.month, time.day)
    end
    
    # Creates either an instead of either Suprdate::Year, Suprdate::Month or Suprdate::Day
    # depending on the number of arguments (parts) used.
    def date(*parts)
      unless DATE_NUM_PARTS_RANGE.include?(parts.nitems)
        raise DateConstructionError.invalid_part_count(parts)
      end
      send(UNIT_NUM_PARTS[parts.nitems], *parts)
    end
    
    # Creates a new DSL paragraph for expressing events (see Suprdate::DSL).
    def event(*args)
      DSL::Paragraph.new(*args).every
    end

    alias :repeats :event
    
    def self.local_methods # :nodoc:
      (instance_methods - superclass.instance_methods - Kernel.methods)
    end
    
    # Returns the names of the methods that create objects. Each name as a singleton #to_export
    # method that can be used to ascertain the name of the exported version of the method that
    # appears on Suprdate.
    def self.builder_methods
      local_methods.reject { |name| name =~ /_/ }.each do |name|
        def name.to_export() capitalize end
      end
    end
    
  end

  DEFAULT_BUILDER = Builder.new

  # Exports the builder_methods on to Suprdate. 
  # So that Suprdate::Day() == Suprdate::DEFAULT_BUILDER.day()
  Builder.builder_methods.each do |name| 
    define_method(name.to_export) { |*args| DEFAULT_BUILDER.send(name, *args) }
  end
  
end
