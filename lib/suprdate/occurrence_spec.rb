require 'rubygems'
require 'aquarium'

module Suprdate
  
  class OccurrenceSpec
    
    # used to specify which methods of this class automatically delimit the current sentence
    def self.delimiter_methods(*methods)
      methods.each do |method|
        aliased_method = method.to_s + '_not_delimited'
        alias_method aliased_method, method
        private aliased_method
        define_method(method) do |*args|
          delimit
          send(aliased_method, *args)
        end
      end
    end
    
    def self.self_returners(*methods)
      methods.each do |method|
        aliased_method = method.to_s + '_not_returning_self'
        alias_method aliased_method, method
        private aliased_method
        define_method(method) do |*args|
          send(aliased_method, *args)
          self
        end
      end
    end
    
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
    
    def happens
      self
    end
    
    #delimiter_methods :sentences, :occurrences, :last_range
    self_returners :to, :from, :delimit, :every
    alias :and :delimit
    
  end
  
  Aquarium::Aspects::Aspect.new :before, 
    :calls_to => [:sentences, :occurrences, :last_rance], 
    :for_type => OccurrenceSpec do |join_point, obj, sym, *args|
    obj.delimit  
  end
  
end