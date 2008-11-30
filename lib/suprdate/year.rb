module Suprdate
  
  class Year
  
    attr_accessor :month_factory, :day_factory, :week_factory, 
                  :week_definition
    attr_reader   :value

    MINIMUM_VALUE = 1582 # year when leap years were first standardized

    def initialize(v) 
      v = v.to_i
      if v < MINIMUM_VALUE
        raise "Attempted to create a year valued #{v}, #{MINIMUM_VALUE - v} less than minimum allowed value of #{MINIMUM_VALUE}"
      end
      @value = v
      self
    end
  
    protected :initialize # for + and -
    
    def <=>(compare) 
      compare = compare.year
      @value - compare.value
    end
  
    def month(*ies)
      ies = [1] if ies.empty?
      disarray(ies.map { |i| new_month(i) })
    end
  
    def +(by) new(@value + by) end
    def -(by) new(@value - by) end
    def succ() self + 1 end
    def months() MONTH_RANGE.to_a.map { |i| new_month(i) }  end
    def days() months.map { |m| m.days }.flatten end
    def day(*args) month(1).day(*args) end
    def inspect() @value.to_s end
    def year() self end
  
    def leap?
      return true  if @value % 400 == 0 
      return false if @value % 100 == 0 
      return true  if @value % 4   == 0 
      false
    end
  
    alias :to_i :value
    alias :since :-
    alias :until :+
    alias :to_s :inspect
    alias :[] :month
    include Comparable
      
    # dup this object and give it a new value
    def new(*args) dup.initialize(*args) end
  
    protected

    def new_month(value)
      month = month_factory.new(self, value)
      month.day_factory = day_factory
      month
    end
    
  end
  
end