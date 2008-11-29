class Month
  
  attr_accessor :day_class
  attr_reader :value, :year
  
  class << self
    
  end
  
  
  def initialize(year, value)
    @year = year
    @value = if value.kind_of?(Symbol)
      MONTH_SYM_TO_I[value]
    elsif MONTH_RANGE.include?(value)
      value
    else
      raise "Month value must specified as symbol or be within range #{MONTH_RANGE.inspect}"
    end
    self
  end
  
  protected :initialize
  
  def to_sym() MONTH_I_TO_SYM[@value] end
  
  def num_days
    return 29 if leap_month?
    NUM_DAYS_IN_MONTHS[@value] 
  end
  
  def days
    (1..num_days).to_a.map { |i| day_class.new(self, i) }
  end
  
  def day(*ies)
    disarray(ies.map { |i| day_class.new(self, i) })
  end
  
  def leap_month?() @value == 2 && @year.leap? end
  def inspect() "#@year-#{@value.to_s.rjust(2, '0')}" end

  def <=>(compare)
    (@year.value * MONTHS_IN_YEAR + @value) - (compare.year.value * MONTHS_IN_YEAR + compare.value)
  end
  
  def since(month) sum - month.sum end
  def until(month) month.sum - sum end
  def +(by) new_from_sum(sum + by) end
  def -(by) new_from_sum(sum - by) end
  def succ() self + 1 end
  def of_year_as_sym() MONTH_I_TO_SYM[@value] end
  def of_year_as_s() MONTH_I_TO_STRING[@value] end
  
  # dup this object and give it a new value
  def new(*args) dup.initialize(*args) end

  alias :to_i :value
  alias :of_year_as_i :value
  alias :to_s :inspect
  alias :[] :day
  include Comparable
  
  protected
    
    # total number of months from 0 years 0 months
    def sum
      @year.value * MONTHS_IN_YEAR + @value - 1   
    end
    
    def new_from_sum(sum)
      new(@year.new(sum / MONTHS_IN_YEAR), sum % MONTHS_IN_YEAR + 1)
    end
  
end