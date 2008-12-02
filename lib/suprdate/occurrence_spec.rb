module Suprdate
  
  class OccurrenceSpec
    
    attr_accessor :name, :builder, :range_factory
    attr_reader :sentences
    
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
    end
    
    {:years => :year, :months => :month, :days => :day}.each_pair do |plural, singular|
      define_method(plural)   { @unit = singular; self }
      define_method(singular) { @unit = singular; self }
    end
    
    def occurrences
      Suprdate.every(@freq, last_range.to_a)
    end
    
    def delimit
      @sentences << {:freq => @freq, :unit => @unit, :to => @to, :from => @from} unless @stored
      @stored = true
    end
    
    def from(*from)
      @from = builder.date(*from)
    end
    
    def to(*to)
      @to = builder.date(*to)
    end
    
    def last_range
      @range_factory.new(@from.send(@unit), @to)
    end
    
    def happens() self end
      
    require 'rubygems'
    require 'aquarium'
    include Aquarium::DSL
    
    alias :and :delimit
    before(:calls_to => [:sentences, :occurrences, :last_range]) { |jpoint, obj, *a| obj.delimit }
    around(:calls_to => [:to, :from, :delimit, :every, :and]) do |jpoint, obj, *a|
      jpoint.proceed
      obj
    end
    
  end
  
end