class WeekDefinition

  def year_from_week(Week) # Year
  def weeks_of_year(Year) # [Week]
  def week_start_offset # Integer
  def use!
    DEFAULT_BUILDER.week_definition = self
  end
  
end

# singleton instances

  ISO8601_WEEK
  USA_WEEK
  UK_WEEK

class Builder
  
  attr_accessor :week_definition
  
end

class Year
  
  def week(Integer) # Week
  def weeks # [Week]

end

class Week

  def attr_accessor :day_factory
  def initialize(Year, Integer)
  def days # [Day]
  def day(Integer || Symbol || String) # Day
  def month # always raises
  def year # Year
  def num_years_spanned # 1 || 2
  def num_months_spanned # 1 || 2
  def of_year # Integer
  def succ # Week
  def prev # Week
  def +(Integer) # Week
  def -(Integer) # Week
  def since(Week) # Integer
  def until(Week) # Integer
  def <=>(Day || Week || Month || Year) # Integer
  def inspect # String

end

class Day
  
  def week

end

# Usage:
  require 'suprdate'
  include Suprdate
  ISO8601_WEEK.use!