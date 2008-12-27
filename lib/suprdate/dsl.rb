module Suprdate
  
  require 'forwardable'
  
  # Contains the classes that make up the language you use to express recurring events. Paragraph, 
  # Sentence and Clause classes are merely designed to capture instructions from the library user.
  # A set of visitors are used to turn those instructions into the desired result. This design 
  # decouples DSL structure from it's implementation.
  module DSL
    
    class ExpressionError < RuntimeError
    
      def self.interval_on_list(list, interval)
        new("Intervals may not be associated with lists: #{interval.inspect} with #{list.inspect}")
      end
      
    end
        
    NO_INTERVAL = 1 # continuous
    DEFAULT_EXCLUSION_STATE = false # include
        
    # Chains together one or more sentences
    class Paragraph
      
      attr_accessor :title, :sentence_factory, :sentences
      
      def initialize(title = 'Chunky bacon')
        @title = title
        @sentence_factory = Sentence
        @sentences = []
      end
      
      def every(*args)
        @sentences << (sentence = @sentence_factory.new(self))
        sentence.every(*args)
      end
      
      def to_hash
        {:title => @title, :sentences => @sentences.map { |sentence| sentence.to_hash } }
      end
      
      def and
        self
      end
      
      alias :serialize :to_hash
            
    end
    
    class ClauseFactory
      
      def make(sentence, list)
        if list.empty?
          clause = RangeClause.new(sentence)
        else
          unless sentence.interval == NO_INTERVAL
            raise ExpressionError.interval_on_list(list, sentence.interval)
          end
          clause = ListClause.new(sentence)
          clause.list = list
        end
        clause
      end
      
    end
    
    # Composed of a single unit (see Supradate::UNIT_CLASSES) that can then be qualified as a list
    # or a range using a repsective clause.
    class Sentence
      
      attr_reader :interval, :unit, :clauses, :exclusion
      attr_accessor :paragraph, :clause_factory
      extend Forwardable
      def_delegators :@paragraph, :serialize, :and
      
      def initialize(paragraph)
        @paragraph = paragraph
        @interval = NO_INTERVAL
        @clauses = []
        @clause_factory = ClauseFactory.new
        @exclusion = DEFAULT_EXCLUSION_STATE
      end
      
      def every(interval = NO_INTERVAL)
        @interval = interval
        self
      end
      
      UNIT_CLASSES.each do |klass|
        define_method(klass.name_singular) do |*list|
          @unit = klass
          @clauses << clause = @clause_factory.make(self, list)
          clause
        end
        alias_method klass.name_plural, klass.name_singular
      end
      
      # traverses down
      def to_hash
        {:clauses => @clauses.map { |clause| clause.to_hash } }
      end
      
      def except
        @exclusion = true
        every
      end
      
      def include
        @exclusion = false
        every
      end
      
    end
    
    class AbstractClause
      
      attr_accessor :sentence, :unit, :exclusion
      extend Forwardable
      def_delegators :@sentence, :every, :serialize, :and, :except, :include
      
      def initialize(sentence)
        @sentence = sentence
        @unit = sentence.unit
        @exclusion = sentence.exclusion
      end
      
      def to_hash
        {:type => :abstract, :unit => @unit, :exclusion => @exclusion}
      end
      
      alias :in :every
      
    end
    
    module ChainAttrAccessor
      
      # Defines methods that allow you to set instance variables without breaking an object chain
      def chain_attr_accessor(*methods_to_define)
        methods_to_define.each do |method_name|
          define_method(method_name) do |*args|
            return instance_variable_get('@' + method_name.to_s) if args.empty?
            instance_variable_set('@' + method_name.to_s, args)
            self
          end
        end
      end
      
    end
    
    class RangeClause < AbstractClause

      attr_accessor :interval

      def initialize(sentence)
        super(sentence)
        @interval = sentence.interval
        @from, @to, @limit = nil
      end

      def to_hash
        super.merge(
          :interval => @interval, :type => :range, :from => @from, :to => @to, :limit => @limit
        )
      end
      
      extend ChainAttrAccessor
      chain_attr_accessor :from, :to, :limit
      alias :times :limit

    end
    
    class ListClause < AbstractClause

      attr_accessor :list
      
      def to_hash
        super.merge(:type => :list, :list => @list)
      end
      
    end
    
  end
  
end