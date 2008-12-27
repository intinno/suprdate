module Suprdate
  
  class Day < Unit
  
    attr_reader :month

    def initialize(month, value)
      @month = month
      unless (1..month.num_days).include? value
        raise DateConstructionError.new("There are not #{value} days in #{month.of_year_as_s}")
      end
      super(value)
    end
    
    protected :initialize
    
    STRFTIME_STR = '%Y-%m-%d'
    
    def inspect() "#@month-#{@value.to_s.rjust(2, '0')}" end
    def year() @month.year end
    
    # This day as a Ruby Time object.
    def time() Time.mktime(*parts) end
      
    # This day as a Ruby Date object.
    def date() Date.new(*parts) end
    
    # This day as a Ruby DateTime object.
    def datetime() DateTime.new(*parts) end
      
    # Polymorphic feature; guarantees you a list of Suprdate::Day
    def days() [self] end
      
    # Polymorphic feature; guarantees you a Suprdate::Day
    def day() self end
      
    # Day of the week as a symbol. (See Suprdate::WEEKDAYS_AS_SYM)
    def of_week_as_sym() WEEKDAYS_AS_SYM[of_week_as_i] end
      
    # Day of the week as a string. (See Suprdate::WEEKDAYS_AS_STR)
    def of_week_as_s() WEEKDAYS_AS_STR[of_week_as_i] end
      
    # Day of the week as an integer. Presently Sunday is 1, Monday is 2 etc.
    def of_week_as_i() date.wday + 1 end
      
    # Day of the year. January 1st is 1.
    def of_year() (date - Date.new(year.value, 1, 1)).numerator + 1 end
      
    # Whether this day is a leap day or, in other words, February 29th.
    def leap?() value == 29 && @month.value == 2 end
      
    # Next successive day.
    def succ() self + 1 end
      
    # Increment by any number of days. A fresh day object is returned.
    def +(increase) new_from_date(date + increase) end
      
    # Decrement by any number of days. A fresh day object is returned.
    def -(decrease) new_from_date(date - decrease) end
      
    # The number of days since another day.
    def since(operand) (date - operand.day.date).numerator end
      
    # The number of days until another day.
    def until(operand) (operand.day.date - date).numerator end
      
    def <=>(operand) 
      return -1 if operand == Infinity
      date <=> operand.day.date 
    end
    
    # If this day is the first Monday of the month this method returns 1.
    # If this day is the second Monday of the month this method returns 2.
    # Works for all days.
    def weekday_occurrence_this_month
      w = of_week_as_i
      w_days_this_month = @month.days[0..value - 1].select do |day|
        day.of_week_as_i == w
      end
      ORDINALS[w_days_this_month.nitems]
    end
    
    alias :of_month :value
  
    private
    
    def parts() [year.value, @month.value, value] end
            
    def new_from_date(date)
      new(@month.new(year.new(date.year), date.month), date.day)
    end
  
  end
  
end