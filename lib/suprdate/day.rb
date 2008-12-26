module Suprdate
  
  class Day
  
    attr_reader :value, :month

    class << self
      include Utility::CleanName
    end

    def initialize(month, value)
      @month = month
      unless (1..month.num_days).include? value
        raise DateConstructionError.new("There aren't #{value} days in #{month.of_year_as_s}")
      end
      @value = value
      self # self return required because initialized is called explicitly in places
    end
    
    STRFTIME_STR = '%Y-%m-%d'
    
    def inspect() "#@month-#{@value.to_s.rjust(2, '0')}" end
    def year() @month.year end
    def time() Time.mktime(*values) end
    def date() Date.new(*values) end
    def datetime() DateTime.new(*values) end
    def days() [self] end
    def day() self end
    def of_week_as_sym() WEEKDAYS_I_TO_SYM[of_week_as_i] end
    def of_week_as_s() WEEKDAYS_I_TO_STRING[of_week_as_i] end
    def of_week_as_i() date.wday + 1 end
    def of_year() (date - Date.new(year.value, 1, 1)).numerator + 1 end
    def leap?() value == 29 && @month.value == 2 end
    def succ() self + 1 end
    def +(increase) new_from_date(date + increase) end
    def -(decrease) new_from_date(date - decrease) end
    def since(operand) (date - operand.day.date).numerator end
    def until(operand) (operand.day.date - date).numerator end
      
    def <=>(operand) 
      return -1 if operand == Inf
      date <=> operand.day.date 
    end
    
    def weekday_occurrence_this_month
      w = of_week_as_i
      w_days_this_month = @month.days[0..value - 1].select do |day|
        day.of_week_as_i == w
      end
      OCCURANCES[w_days_this_month.nitems]
    end
    
    alias :to_s :inspect
    alias :to_i :value
    alias :of_month :value
    include Comparable
    protected :initialize
  
    private
    
    def values() [year.value, @month.value, value] end
      
    # dup this object and give it a new value
    def new(*args) dup.initialize(*args) end
      
    def new_from_date(date)
      new(@month.new(year.new(date.year), date.month), date.day)
    end
  
  end
  
end