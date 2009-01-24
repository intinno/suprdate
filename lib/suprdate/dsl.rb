module Suprdate
  
  require 'forwardable'
  
  # Contains the classes that make up the language you use to express recurring events. Paragraph, 
  # Sentence and Clause classes (elements) are merely designed to capture instructions from the 
  # developer. A set of visitors are used to turn those instructions into the desired result. 
  # This design decouples DSL structure from it's implementation.
  module DSL
    
    # Most abstract class of paragraphs, sentences and clauses
    # All DSL elements provide
    class Element
      
      attr_accessor :english_serializer_factory
      
      def initialize
        @english_serializer_factory = SerializationToEnglish
      end
      
      def to_english
        @english_serializer_factory.new.convert(serialize)
      end
      
    end
    
    # Converts a DSL serialization into human readable English.
    class SerializationToEnglish

      # Perform the conversion, returns a string.
      def convert(serialization)
        words = [serialization[:title]]
        serialization[:sentences].each do |sentence|
          next words << 'never happens' if sentence[:clauses].empty?
          sentence[:clauses].each do |clause|
            clause.extend(SerializationClauseHelper)
            if clause[:type] == :range
              words << 'happens every'
              words << clause[:interval] if clause.has_interval
            end
            words << clause.unit_name
          end
        end
        words.map { |x| x.to_s }.join(' ')
      end
      
    end
    
    module SerializationClauseHelper
      
      def unit_name() self[:unit].send(has_interval ? :name_plural : :name_singular) end
      def has_interval() self[:interval] > 1 end
        
    end

    # Raised when you're trying to do weird things that aren't possible with the DSL
    # More often than not you'll just get a NoMethodError when using the DSL incorrectly.
    class ExpressionError < RuntimeError
    
      # Helper for formatting error message.
      def self.interval_on_list(list, interval)
        new("Intervals may not be associated with lists: #{interval.inspect} with #{list.inspect}")
      end
      
      def self.endianness(a, b)
        new("Cannot have a unit that is smaller or equally significant follow the last. You had #{a} following #{b}")
      end
      
    end
        
    CONTINUOUS = 1 # Relates to intervals; More human way of saying something that happens every 1 day.
    DEFAULT_EXCLUSION_STATE = false # as in: include.
        
    # Chains together one or more sentences and gives them a title.
    class Paragraph < Element
      
      attr_accessor :title, :sentence_factory, :sentences
      
      def initialize(title = 'Chunky bacon')
        @title = title
        @sentence_factory = Sentence
        @sentences = []
        super()
      end
      
      # Allows it to acts as a sentence.
      def every(*args)
        @sentences << (sentence = @sentence_factory.new(self))
        sentence.every(*args)
      end
      
      # Serialized representation of the data collected.
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
          unless sentence.interval == CONTINUOUS
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
    class Sentence < Element
      
      attr_reader :interval, :unit, :clauses, :exclusion
      attr_accessor :paragraph, :clause_factory
      extend Forwardable
      def_delegators :@paragraph, :serialize, :and
      
      def initialize(paragraph)
        @paragraph = paragraph
        @interval = CONTINUOUS
        @clauses = []
        @clause_factory = ClauseFactory.new
        @exclusion = DEFAULT_EXCLUSION_STATE
        super()
      end
      
      def every(interval = CONTINUOUS)
        @interval = interval
        self
      end
      
      # Creates a method of the plural and singular of each unit for designating a unit
      # and returns a clause.
      UNIT_CLASSES.each do |klass|
        define_method(klass.name_singular) do |*list|
          assert_correct_endianness(klass)
          @unit = klass
          @clauses << clause = @clause_factory.make(self, list)
          clause
        end
        alias_method klass.name_plural, klass.name_singular
      end
      
      # Serialized representation of the data collected. 
      # Call #serialize to get the whole thing.
      def to_hash
        {:clauses => @clauses.map { |clause| clause.to_hash } }
      end
      
      # Raises if the current unit is larger than the incoming one (little endian)
      # i.e. Days then weeks then months then years -- with any number of intermediates omitted. 
      def assert_correct_endianness(incoming)
        return true if @clauses.empty?
        if @clauses.last.unit >= incoming
          raise ExpressionError.endianness(@clauses.last.unit, incoming) 
        end
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
    
    module ChainAttrAccessor
      
      # Defines methods that allow you to set instance variables without breaking an object chain
      # 
      # Example:
      #   class Foo
      #     extend ChainAttrAccessor
      #     chain_attr_accessor :bar, :zim
      #   end
      #   inst = Foo.new
      #   inst.bar(10).zim(9) # => #<Foo:0x10c3090>
      #   inst.bar # => 10
      #   inst.zim # => 9
      # 
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
    
    class Clause < Element
      
      attr_accessor :sentence, :unit, :exclusion
      extend Forwardable
      def_delegators :@sentence, :every, :serialize, :and, :except, :include
      
      def initialize(sentence)
        @sentence = sentence
        @unit = sentence.unit
        @exclusion = sentence.exclusion
        super()
      end
      
      # Serialized representation of the data collected. 
      # Call #serialize to get the whole thing.
      def to_hash
        {:type => :abstract, :unit => @unit, :exclusion => @exclusion}
      end
      
      alias :in :every
      
    end
    
    # For specifing ranges of date units
    class RangeClause < Clause

      attr_accessor :interval

      def initialize(sentence)
        super(sentence)
        @interval = sentence.interval
        @from, @to, @limit = nil
      end

      # Serialized representation of the data collected. 
      # Call #serialize to get the whole thing.
      def to_hash
        super.merge(
          :interval => @interval, :type => :range, :from => @from, :to => @to, :limit => @limit
        )
      end
      
      extend ChainAttrAccessor
      chain_attr_accessor :from, :to, :limit
      alias :times :limit

    end
    
    # For specifing specific date units
    class ListClause < Clause

      attr_accessor :list
      
      # Serialized representation of the data collected. 
      # Call #serialize to get the whole thing.
      def to_hash
        super.merge(:type => :list, :list => @list)
      end
      
    end
    
  end
  
end