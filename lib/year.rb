class Year
  
  attr_accessor :month_class, 
                :week_class, 
                :week_definition
  attr_reader   :value

  MINIMUM_VALUE = 1582 # year when leap years first came to be standardized

  def initialize(v) 
    v = v.to_i
    if v < MINIMUM_VALUE
      raise "Attempted to create a year valued #{v}, #{MINIMUM_VALUE - v} less than minimum allowed value of #{MINIMUM_VALUE}"
    end
    @value = v
    self
  end
  
  protected :initialize # for + and -
  
  def +(by) dup.initialize(@value + by) end
  def -(by) dup.initialize(@value - by) end
  def <=>(compare) @value - compare.value  end
  def succ() self + 1 end
  
  def months
    MONTH_RANGE.to_a.map { |index| month_class.new(self, index) } 
  end
  
  def month(*indexes)
    disarray(indexes.map { |index| month_class.new(self, index) })
  end
  
  def days
    months.map { |m| m.days }.flatten
  end
  
  def leap?
    return true  if @value % 400 == 0 
    return false if @value % 100 == 0 
    return true  if @value % 4   == 0 
    false
  end
  
  def inspect
    "#{self.class} #{@value}"
  end
  
  include Comparable
  
  alias :to_i :value
  alias :since :-
  alias :until :+
  
end