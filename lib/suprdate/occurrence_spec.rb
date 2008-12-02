module Suprdate
  
  class OccurrenceSpec
    
    attr_accessor :name, :builder, :range_factory
    
    def initialize(name = 'Chunky bacon', builder = nil)
      @name = name
      @builder = builder || DEFAULT_BUILDER.dup
      @range_factory = Range
    end
    
    def every(freq = 1)
      @to = nil
      @from = nil
      @freq = freq
      self
    end
    
    def year
      @unit = :year
      self
    end
    
    def month
      @unit = :month
      self
    end
    
    def day
      @unit = :day
      self
    end
    
    def from(*from)
      @from = builder.date(*from)
      self
    end
    
    def to(*to)
      @to = builder.date(*to)
      self
    end
    
    def range
      @range_factory.new(@from.send(@unit), @to)
    end
    
  end
  
end