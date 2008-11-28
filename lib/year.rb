class Year
  
  attr_accessor :month_class, 
                :week_class, 
                :day_class, 
                :week_definition
  attr_reader   :value

  def initialize(value)
    @value = value
  end
  
  def +(by)
    self.class.new(@value += by)
  end
  
  def -(by)
    self.class.new(@value -= by)
  end
  
  def <=>(compare)
    @value - compare.to_i 
  end
  
  def succ
    self.class.new(@value + 1)
  end
  
  def months
    (1..12).to_a.map { |index| month_class.new(self, index) } 
  end
  
  include Comparable
  
  alias :to_i :value
  
end

