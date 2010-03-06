module Suprdate

  class Month < Unit

    attr_accessor :day_factory
    attr_reader :year

    STRFTIME_STR = '%Y-%m'

    def initialize(year, value)
      @year = year
      @value = if value.kind_of?(Symbol)
        MONTHS_SYM_TO_I.fetch(value)
      else
        unless MONTH_RANGE.include?(value)
          raise "Month value must specified as symbol or be within range #{MONTH_RANGE.inspect}"
        end
        value
      end
      self # intentional
    end

    protected :initialize

    # Name of month as symbol.
    def to_sym() MONTHS_AS_SYM[@value] end

    # Number of day in this month.
    def num_days
      return 29 if leap?
      NUM_DAYS_IN_MONTHS[@value]
    end

    # All the days in this month
    def days
      (1..num_days).to_a.map { |i| day_factory.new(self, i) }
    end

    # A choice of some specific days from this month.
    def day(*indices)
      indices = [1] if indices.empty?
      rval = indices.map do |i|
        i = num_days + 1 - i.abs if i < 0
        day_factory.new(self, i)
      end
      Utility::disarray(rval)
    end

    # Whether this month contains a leap day.
    def leap?() @value == 2 && @year.leap? end

    def inspect() "#@year-#{@value.to_s.rjust(2, '0')}" end

    def <=>(operand)
      return -1 if operand == Infinity
      operand = operand.month
      (@year.value * NUM_MONTHS_IN_YEAR + @value) - (operand.year.value * NUM_MONTHS_IN_YEAR + operand.value)
    end

    # Number of months since parameter#month.
    def since(operand) sum - operand.month.sum end

    # Number of months until parameter#month.
    def until(operand) operand.month.sum - sum end

    # Return a new month incremented by an integer.
    def +(increase) new_from_sum(sum + increase) end

    # Return a new month decremented by an integer.
    def -(decrease) new_from_sum(sum - decrease) end

    # Next successive month.
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
