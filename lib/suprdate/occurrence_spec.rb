module Suprdate
  
  class OccurrenceSpec
    
    attr_accessor :name, :builder, :range_factory
    
    def initialize(name = 'Chunky bacon', builder = nil)
      @name = name
      @builder = builder || DEFAULT_BUILDER
      @range_factory = Range
    end
    
    def every(freq = 1)
      @to = @from = nil
      @freq = freq
      self
    end
    
    [:year, :month, :day].each do |unit|
      define_method(unit) { @unit = unit; self }
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