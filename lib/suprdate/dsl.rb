module Suprdate
  
  require 'forwardable'

  def event(*args)
    DSL::Paragraph.new(*args)
  end
  
  # Contains the classes that make up the language you use to express recurring events. Paragraph, 
  # Sentence and Clause classes are merely designed to capture instructions from the library user.
  # A set of visitors are used to turn those instructions into the desired result. This design 
  # decouples DSL structure from it's implementation.
  module DSL
        
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
          clause = ListClause.new(sentence)
          clause.list = list
        end
        clause
      end
      
    end
    
    # Composed of a single unit (see Supradate::UNIT_CLASSES) that can then be qualified as a list
    # or a range using a repsective clause.
    class Sentence
      
      DEFAULT_INTERVAL = 1
      attr_reader :interval, :unit, :clauses
      attr_accessor :paragraph, :clause_factory
      extend Forwardable
      def_delegators :@paragraph, :serialize, :and
      
      def initialize(paragraph)
        @paragraph = paragraph
        @interval = DEFAULT_INTERVAL
        @clauses = []
        @clause_factory = ClauseFactory.new
      end
      
      def every(interval = DEFAULT_INTERVAL)
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
      
    end
    
    class AbstractClause
      
      attr_accessor :sentence, :unit, :interval
      extend Forwardable
      def_delegators :@sentence, :every, :serialize, :and
      
      def initialize(sentence)
        @sentence = sentence
        # these instance variables will change when the next clause 
        # is added to sentence so they must be copied here
        @unit = sentence.unit
        @interval = sentence.interval
      end
      
      def to_hash
        {:type => :abstract, :interval => @interval, :unit => @unit}
      end
      
      alias :in :sentence
      
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

      def initialize(*args)
        super(*args)
        @from = nil
        @to = nil
        @limit = nil
      end

      def to_hash
        super.merge(:type => :range, :from => @from, :to => @to, :limit => @limit)
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