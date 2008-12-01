module Suprdate

  class Month
  
    attr_accessor :day_factory
    attr_reader :value, :year
  
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
      (1..num_days).to_a.map { |i| day_factory.new(self, i) }
    end
  
    def day(*ies)
      ies = [1] if ies.empty?
      disarray(ies.map do |i|
        i = num_days + i + 1 if i < 0
        day_factory.new(self, i)
      end)
    end
  
    def leap_month?() @value == 2 && @year.leap? end
    def inspect() "#@year-#{@value.to_s.rjust(2, '0')}" end

    def <=>(opperand)
      return -1 if opperand == Inf
      opperand = opperand.month
      (@year.value * NUM_MONTHS_IN_YEAR + @value) - (opperand.year.value * NUM_MONTHS_IN_YEAR + opperand.value)
    end
  
    def since(opperand) sum - opperand.month.sum end
    def until(opperand) opperand.month.sum - sum end
    def +(increase) new_from_sum(sum + increase) end
    def -(decrease) new_from_sum(sum - decrease) end
    def succ() self + 1 end
    def of_year_as_sym() MONTH_I_TO_SYM[@value] end
    def of_year_as_s() MONTH_I_TO_STRING[@value] end
    def month() self end
  
    alias :to_i :value
    alias :of_year_as_i :value
    alias :to_s :inspect
    alias :[] :day
    include Comparable
  
    # dup this object and give it a new value
    def new(*args) dup.initialize(*args) end

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