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
      
      attr_accessor :title
      
      def initialize(title = 'Chunky bacon')
        @title = title
      end
      
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
      
      # Refactor candidate: generate these methods from UNIT_CLASSES
      
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
      
      def to_hash
        {:interval => @interval, :clauses => @clauses.map { |clause| clause.to_hash } }
      end
      
      # traverses up
      def serialize(*args)
        @paragraph.serialize(*args)
      end
      
      alias :months :month
      alias :years :year
      alias :days :day
      
      protected
      
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
      
      def reset() end
        
      def every(*args)
        @sentence.every(*args)
      end
      
      # traverses up
      def serialize(*args)
        @sentence.serialize(*args)
      end
      
      def to_hash
        {:unit => @unit}
      end
      
      alias :in :sentence
      
    end
    
    class RangeClause < AbstractClause

      def to_hash() super.merge(:from => @from, :to => @to) end

    end
    
    class ListClause < AbstractClause

      attr_accessor :list
      
      def to_hash() super.merge(:list => @list) end
      
    end
    
  end
  
end