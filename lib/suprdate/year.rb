module Suprdate
  
  class Year
  
    attr_accessor :month_factory, :day_factory, :week_factory, :week_definition
    attr_reader   :value
    
    class << self
      include Utility::CleanName
    end

    MINIMUM_VALUE = 1582 # year when leap years were first standardized
    STRFTIME_STR = '%Y'

    def initialize(v) 
      v = v.to_i
      raise DateConstructionError.new(
        "Attempted to create a year valued #{v}, #{MINIMUM_VALUE - v} less than minimum " +
        "allowed value of #{MINIMUM_VALUE}"
      ) if v < MINIMUM_VALUE
      @value = v
      self # self return required because initialized is called explicitly in places
    end
    
    protected :initialize # for + and -
    
    def <=>(operand) 
      return -1 if operand == Inf
      operand = operand.year
      @value - operand.value
    end
  
    def month(*indices)
      indices = [1] if indices.empty?
      Utility::disarray(indices.map { |i| new_month(i) })
    end
  
    def +(increase) new(@value + increase) end
    def -(decrease) new(@value - decrease) end
    def succ() self + 1 end
    def months() MONTH_RANGE.to_a.map { |i| new_month(i) }  end
    def days() months.map { |m| m.days }.flatten end
    def day(*args) month(1).day(*args) end
    def inspect() @value.to_s end
    def year() self end
    def since(year) @value - year.value end
    def until(year) year.value - @value end
  
    def leap?
      return true  if @value % 400 == 0 
      return false if @value % 100 == 0 
      return true  if @value % 4   == 0 
      false
    end
  
    alias :to_i :value
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