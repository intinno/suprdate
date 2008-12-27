module Suprdate

  class Month < Unit
  
    attr_accessor :day_factory
    attr_reader :year
  
    STRFTIME_STR = '%Y-%m'

    def initialize(year, value)
      @year = year
      @value = if value.kind_of?(Symbol)
        MONTHS_SYM_TO_I[value]
      elsif MONTH_RANGE.include?(value)
        value
      else
        raise "Month value must specified as symbol or be within range #{MONTH_RANGE.inspect}"
      end
      self # intentional
    end
    
    protected :initialize
  
    def to_sym() MONTHS_AS_SYM[@value] end
  
    def num_days
      return 29 if leap_month?
      NUM_DAYS_IN_MONTHS[@value] 
    end
  
    def days
      (1..num_days).to_a.map { |i| day_factory.new(self, i) }
    end
  
    def day(*indices)
      indices = [1] if indices.empty?
      rval = indices.map do |i|
        i = num_days + 1 - i.abs if i < 0
        day_factory.new(self, i)
      end
      Utility::disarray(rval)
    end
  
    def leap_month?() @value == 2 && @year.leap? end
    def inspect() "#@year-#{@value.to_s.rjust(2, '0')}" end

    def <=>(operand)
      return -1 if operand == Infinity
      operand = operand.month
      (@year.value * NUM_MONTHS_IN_YEAR + @value) - (operand.year.value * NUM_MONTHS_IN_YEAR + operand.value)
    end
  
    def since(operand) sum - operand.month.sum end
    def until(operand) operand.month.sum - sum end
    def +(increase) new_from_sum(sum + increase) end
    def -(decrease) new_from_sum(sum - decrease) end
    def succ() self + 1 end
    def of_year_as_sym() MONTHS_AS_SYM[@value] end
    def of_year_as_s() MONTHS_AS_STR[@value] end
    def month() self end
  
    alias :of_year_as_i :value
    alias :[] :day
  
    protected
    
    # total number of months from 0 years 0 months
    def sum
      @year.value * NUM_MONTHS_IN_YEAR + @value - 1   
    end
  
    def new_from_sum(sum)
      new(@year.new(sum / NUM_MONTHS_IN_YEAR), sum % NUM_MONTHS_IN_YEAR + 1)
    end
  
  end

end