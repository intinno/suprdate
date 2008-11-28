class Day
  
  attr_reader :value

  def initialize(month, value)
    @month = month
    @value = value
  end
  
  def inspect() "#@month-#{@value.to_s.rjust(2, '0')}" end
  
  alias :to_s :inspect
  alias :to_i :value
  
end