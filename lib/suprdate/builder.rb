module Suprdate
  
  # for creating date objects such as year, months and days
  class Builder
  
    attr_accessor :day_factory, :month_factory, :week_definition
    
    # the number of parameters that the date method will accept
    NUM_PARTS_RANGE = 1..3
    # the metods that will be called for number of parts
    METHODS_FOR_NUM_PARTS = [nil, :year, :month, :day] 
    
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
      @day_factory.new(month(year_value, month_value), day_value)
    end
  
    def today
      time = Time.now
      day(time.year, time.month, time.day)
    end
    
    def date(*parts)
      unless NUM_PARTS_RANGE.include?(parts.nitems)
        raise ArgumentError.new(
          'Expecting #{NUM_PARTS_RANGE} number arguments but received #{parts.nitems}'
        ) 
      end
      send(METHODS_FOR_NUM_PARTS[parts.nitems], *parts)
    end
    
    def repeats(name = 'Chunky bacon', builder = nil)
      RepetitionRules.new(name, builder || self)
    end
    
    # returns the names of the methods that actually build stuff
    def self.building_methods
      (instance_methods - superclass.instance_methods - Kernel.methods).reject { |name| name =~ /_/ }
    end
  
  end

  DEFAULT_BUILDER = Builder.new

  # defines the important methods of DEFAULT_BUILDER as stand alone module methods
  Builder.building_methods.each do |name| 
    define_method(name.capitalize) { |*args| DEFAULT_BUILDER.send(name, *args) }
  end
  
end