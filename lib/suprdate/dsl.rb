module Suprdate
  
  module DSL
    
    def self.event(*args)
      Paragraph.new(*args)
    end
    
    class Paragraph
      
      attr_accessor :title
      
      def initialize(title = 'Chunky bacon')
        @title = title
      end
      
    end
    
    class Sentence
      
      DEFAULT_INTERVAL = 1
      attr_reader :interval, :unit, :clauses
      
      def initialize
        @interval = DEFAULT_INTERVAL
        @clauses = []
      end
      
      def every(interval = DEFAULT_INTERVAL)
        @interval = interval
        self
      end
      
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
    
    class Clause
      
      attr_reader :sentence, :unit
      
      def initialize(sentence)
        @sentence = sentence
        @unit = sentence.unit
      end
      
    end
    
    class RangeClause < Clause

    end
    
    class ListClause < Clause

      attr_accessor :list
      
    end
    
  end
  
end