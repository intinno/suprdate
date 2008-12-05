module Suprdate
  
  class RepetitionRulesSentence
    
  end
  
  class RepetitionRules
    
    attr_accessor :name, :builder
    
    def initialize(name, builder)
      @name = name
      @builder = builder
      @sentences = []
      fresh_sentence
    end
    
    protected 
    
      def fresh_sentence
        @unit = @from = nil
        @to = Inf 
        @every = 1
      end
    
      def store
        unless @unit
          raise @name + ' sentence missing unit specification clause such as year, month or day'
        end
        unless @from
          raise @name + ' sentence missing required clause: "from"'
        end
        @sentences << {:every => @every, :unit => @unit, :to => @to, :from => @from} unless @stored
        fresh_sentence
        @stored = true
      end
    
    public
    
      {:years => :year, :months => :month, :days => :day}.each_pair do |plural, singular|
        define_method(plural)   { @unit = singular; self }
        define_method(singular) { @unit = singular; self }
      end
    
      # fresh_sentenceing methods
    
      def occurrences
        store
        Suprdate.every(@every, last_range.to_a)
      end
    
      def and
        store
        self
      end
    
      def last_range
        store
        Range.new(@from.send(@unit), @to)
      end
    
      def sentences() store; @sentences end
    
      # clauses
    
      def every(every = 1)
        @every = every
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
    
      def happens() self end
      
      alias :until :to
    
  end
  
end