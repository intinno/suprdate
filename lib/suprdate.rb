module Suprdate
  
  BASE_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  LIB_DIR = File.join(BASE_DIR,"lib")
  
  # Methods and classes used in the internals of Suprdate not expected to be of concern to the
  # casual developer.
  module Utility # :nodoc: all
    
    def self.disarray(array) 
      if array.size == 1 then array[0] else array end
    end
    
    # Some inflection on the #name of constants.
    module CleanConstantName
    
      # Lowercase name without preceding namespace.
      def name_singular() name_without_namespace.downcase end
      
      # Same as #name_singular with an 's' added.
      def name_plural() name_singular + 's' end
      
      # Symbol of lowercase name without preceding namespace.
      def to_sym() name_singular.to_sym end
  
      private
  
      def name_without_namespace
        name[to_s.rindex('::') + 2 .. -1]
      end

    end
  
  end

  # Filters the elements from a list by their index according to the specified ordinal. Ordinal
  # may be specified as an integer or symbol (see ORDINALS). Results are provided either as a 
  # returned list or code block accepting a single parameter. If a block is given the return value 
  # becomes the original, unaltered, list.
  def every(ordinal, list, &block)
    ordinal = ORDINALS_SYM_TO_I.fetch(ordinal) if ordinal.kind_of?(Symbol)
    rval = if block
      list
    else
      block = lambda { |x| rval << x } 
      []
    end
    list.each_with_index do |value, index|
      block.call(value) if index % ordinal == 0
    end
    rval
  end
  
  # Used in ranges to specify a range that has no upper limit
  module Infinity; end
  
  # The number of possible parts that can make up either a year, month, or day
  DATE_NUM_PARTS_RANGE = 1..3
  # The unit associated each each number of parts
  UNIT_NUM_PARTS = [nil, :year, :month, :day] 
  
  # Errors caused by attempting to construct date objects that cannot be
  class DateConstructionError < RuntimeError
  
    def self.invalid_part_count(parts)
      new('Expected a number arguments (parts) within range #{DATE_NUM_PARTS_RANGE} ' + 
          'but received #{parts.nitems}')
    end
    
  end
  
  # Abstract superclass class for Year, Month, Day, etc.
  class Unit
    
    attr_reader :value
    alias :to_i :value
    
    extend Utility::CleanConstantName
    include Comparable
    
    def to_s() inspect end
    
    def initialize(value)
      @value = value
      self # intentional
    end
    
    # Duplicates this object and reinitialize it
    def new(*args) dup.initialize(*args) end
    
  end
  
end

require Suprdate::LIB_DIR + '/suprdate/day'
require Suprdate::LIB_DIR + '/suprdate/month'
require Suprdate::LIB_DIR + '/suprdate/year'
require Suprdate::LIB_DIR + '/suprdate/builder'

module Suprdate
    
  UNIT_CLASSES = [Year, Month, Day]
  
  # Cheeky helper
  def UNIT_CLASSES.fetch_index(i)
    index = index(i)
    return index if index
    raise IndexError("#{i} does not exist within UNIT_CLASSES")
  end

  WEEKDAYS_SYM_TO_I = {
    :mon => 1, :tue => 2, :wed => 3, :thu => 4, 
    :fri => 5, :sat => 6, :sun => 7
  }

  WEEKDAYS_AS_SYM = [nil, :sun, :mon, :tue, :wed, :thu, :fri, :sat]

  WEEKDAYS_AS_STR = [
    nil, 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ]

  WEEKDAY_RANGE = 1..7

  MONTHS_SYM_TO_I = {
    :jan => 1,    :feb => 2,    :mar => 3,
    :apr => 4,    :may => 5,    :jun => 6,
    :jul => 7,    :aug => 8,    :sep => 9,
    :oct => 10,   :nov => 11,   :dec => 12,
  }

  MONTHS_AS_SYM = [
    nil, :jan, :feb, :mar, :apr, :may, :jun, :jul,
    :aug, :sep, :oct, :nov, :dec
  ]

  MONTHS_AS_STR = [
    nil, 'January', 'February', 'March', 'April', 
    'May', 'June', 'July', 'August', 'September', 
    'October', 'November', 'December'
  ]

  NUM_MONTHS_IN_YEAR = 12
  
  MONTH_RANGE = 1..NUM_MONTHS_IN_YEAR
  
  NUM_DAYS_IN_MONTHS = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  
  ORDINALS = [nil, :first, :second, :third, :fourth, :fifth]
  
  ORDINALS_SYM_TO_I = {
    :first => 1, :second  => 2, :third  => 3, :fourth => 4, :fifth => 5,
    :sixth => 6, :seventh => 7, :eighth => 8, :ninth  => 9, :tenth => 10
  }
  
end

require Suprdate::LIB_DIR + "/suprdate/dsl"