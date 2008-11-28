class Month
  
  attr_reader :value
  
  def initialize(year, value)
    @year = year
    @value = if value.kind_of?(Symbol)
      MONTH_SYM_TO_I[value]
    elsif MONTH_RANGE.include?(value)
      value
    else
      raise "Month value must specified as symbol or be within range #{MONTH_RANGE.inspect}"
    end
  end
  
  def to_sym
    MONTH_I_TO_SYM[@value]
  end

  alias :to_i :value
  
end