module Suprdate
  
  
  # Contains the classes that make up the language you use to express recurring events. Paragraph, 
  # Sentence and Clause classes are merely designed to capture instructions from the library user.
  # A set of visitors are used to turn those instructions into the desired result. This design 
  # decouples DSL structure from it's implementation.
  module DSL
    
    def self.event(*args)
      Paragraph.new(*args)
    end
    
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
      
      alias :serialize :to_hash
            
    end
    
    # Composed of a single unit (see Supradate::UNIT_CLASSES) that can then be qualified as a list
    # or a range using a repsective clause.
    class Sentence
      
      DEFAULT_INTERVAL = 1
      attr_reader :interval, :unit, :clauses
      attr_accessor :paragraph
      
      def initialize(paragraph)
        @paragraph = paragraph
        @interval = DEFAULT_INTERVAL
        @clauses = []
      end
      
      def every(interval = DEFAULT_INTERVAL)
        @interval = interval
        self
      end
      
      def and
        @paragraph.and
      end
      
      # CONSIDERATION: generate these methods from UNIT_CLASSES (use to_word(true|false))
      
      def year(*list)
        @unit = Year
        add_clause(list)
      end
      
      def month(*list)
        @unit = Month
        add_clause(list)
      end
      
      def day(*list)
        @unit = Day
        add_clause(list)
      end
      
      # traverses up
      def serialize(*args)
        @paragraph.serialize(*args)
      end
      
      # traverses down
      def to_hash
        {:interval => @interval, :clauses => @clauses.map { |clause| clause.to_hash } }
      end
      
      alias :months :month
      alias :years :year
      alias :days :day
      
      protected
      
        # CONSIDERATION: extract class; factory that makes this decision
        def add_clause(list)
          if list.empty?
            clause = RangeClause.new(self)
          else
            clause = ListClause.new(self)
            clause.list = list
          end
          @clauses << clause
          clause
        end
        
    end
    
    class AbstractClause
      
      attr_reader :sentence, :unit
      
      def initialize(sentence)
        @sentence = sentence
        @unit = sentence.unit
      end
      
      def every(*args)
        @sentence.every(*args)
      end
      
      # traverses up
      def serialize(*args)
        @sentence.serialize(*args)
      end
      
      def to_hash
        {:unit => @unit, :type => :abstract}
      end
      
      alias :in :sentence
      
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
      
      # TODO: use define_method to generate these hybrid accessors
      
      def from(*args)
        return @from if args.empty?
        @from = args
        self
      end
      
      def to(*args)
        return @to if args.empty?
        @to = args
        self
      end
      
      def limit(*args)
        return @limit if args.empty?
        @limit = args
        self
      end
      
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