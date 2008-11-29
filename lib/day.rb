class Day
  
  attr_reader :value, :month

  def initialize(month, value)
    @month = month
    @value = value
  end
  
  def inspect() "#@month-#{@value.to_s.rjust(2, '0')}" end
  def year() @month.year end
  def time() Time.mktime(*values) end
  def date() Date.new(*values) end
  def datetime() DateTime.new(*values) end
  def days() [self] end
  def of_week_as_sym() WEEKDAYS_I_TO_SYM[of_week_as_i] end
  def of_week_as_s() WEEKDAYS_I_TO_STRING[of_week_as_i] end
  def of_week_as_i() date.wday end
  def of_year() self.class.new(@month.new(year, 1)).since(self) end
  def leap?() value == 29 && @month.value == 2 end
  def succ() self + 1 end
  
  alias :to_s :inspect
  alias :to_i :value
  alias :of_month :value
  
  private
    
    def values() [year.value, @month.value, value] end
  
end