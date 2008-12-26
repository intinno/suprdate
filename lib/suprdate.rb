module Suprdate
  
  BASE_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  LIB_DIR = File.join(BASE_DIR,"lib")
  
  module Utility
    
    def self.disarray(array) 
      if array.size == 1 then array[0] else array end
    end
    
    # some inflection on the #name of something
    module CleanName
    
      def name_singular 
        name_without_namespace.downcase
      end
      
      def name_plural
        name_singular + 's'
      end
      
      def to_sym() 
        name_without_namespace.downcase.to_sym
      end
  
      private
  
        def name_without_namespace
          name[to_s.rindex('::') + 2 .. -1]
        end

    end
  
  end

  # filters elements from lists at specified frequency
  # freq may be specified as an integer or symbol
  def every(freq, list, &block)
    if freq.kind_of?(Symbol)
      freq = OCCURANCES_SYM_TO_I[freq]
      raise 'Specified symbol does not specify a known frequency' if freq.nil?
    end
    rval = if block
      list
    else
      block = lambda { |x| rval << x } 
      []
    end
    list.each_with_index do |value, key|
      block.call(value) if key % freq == 0
    end
    rval
  end
  
  module Inf; end
  
  class DateConstructionError < RuntimeError; end
  
end

require Suprdate::LIB_DIR + '/suprdate/day'
require Suprdate::LIB_DIR + '/suprdate/month'
require Suprdate::LIB_DIR + '/suprdate/year'
require Suprdate::LIB_DIR + '/suprdate/builder'

module Suprdate
    
  UNIT_CLASSES = [Year, Month, Day]

  WEEKDAYS_SYM_TO_I = {
    :mon => 1, :tue => 2, :wed => 3, :thu => 4, 
    :fri => 5, :sat => 6, :sun => 7
  }

  WEEKDAYS_I_TO_SYM = [
    nil, :sun, :mon, :tue, :wed, :thu, :fri, :sat
  ]

  WEEKDAYS_I_TO_STRING = [
    nil, 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ]

  MONTH_SYM_TO_I = {
    :jan => 1,    :feb => 2,    :mar => 3,
    :apr => 4,    :may => 5,    :jun => 6,
    :jul => 7,    :aug => 8,    :sep => 9,
    :oct => 10,   :nov => 11,   :dec => 12,
  }

  MONTH_I_TO_SYM = [
    nil, :jan, :feb, :mar, :apr, :may, :jun, :jul,
    :aug, :sep, :oct, :nov, :dec
  ]

  MONTH_I_TO_STRING = [
    nil, 'January', 'February', 'March', 'April', 
    'May', 'June', 'July', 'August', 'September', 
    'October', 'November', 'December'
  ]

  NUM_MONTHS_IN_YEAR = 12
  
  MONTH_RANGE = 1..NUM_MONTHS_IN_YEAR
  
  NUM_DAYS_IN_MONTHS = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  
  OCCURANCES = [nil, :first, :second, :third, :fourth, :fifth]
  
  OCCURANCES_SYM_TO_I = {
    :first => 1, :second  => 2, :third  => 3, :fourth => 4, :fifth => 5,
    :sixth => 6, :seventh => 7, :eighth => 8, :ninth  => 9, :tenth => 10
  }
  
  WEEKDAY_RANGE = 1..7
  
end

require Suprdate::LIB_DIR + "/suprdate/dsl"