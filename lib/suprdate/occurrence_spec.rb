module Suprdate
  
  class OccurrenceSpec
    
    attr_accessor :name, :builder, :range_factory
    
    def initialize(name = 'Chunky bacon', builder = nil)
      @name = name
      @builder = builder || DEFAULT_BUILDER
      @range_factory = Range
      @sentences  = []
    end
    
    def every(freq = 1)
      @stored = false
      @to = Inf 
      @from = nil
      @freq = freq
      self
    end
    
    {:years => :year, :months => :month, :days => :day}.each_pair do |plural, singular|
      define_method(plural)   { @unit = singular; self }
      define_method(singular) { @unit = singular; self }
    end
    
    def self.delimit_with(*methods)
      
    end
    
    delimit_with :sentences, :occurrences
    
    def occurrences
      self.and
      Suprdate.every(@freq, last_range.to_a)
    end
    
    def and
      @sentences << {:freq => @freq, :unit => @unit, :to => @to, :from => @from} unless @stored
      @stored = true
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
    
    def last_range
      @range_factory.new(@from.send(@unit), @to)
    end
    
    def sentences
      self.and
      @sentences
    end
    
  end
  
end