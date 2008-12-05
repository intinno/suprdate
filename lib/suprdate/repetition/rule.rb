module Suprdate::Repetition

  class Rule

    attr_accessor :from, :to, :every, :except, :unit

    def initialize
      @limit = nil
      @from = Today()
      @to = Inf
      @except = [] # instances of self, Year, Month, Day or Week
      @every = 1
      @unit = nil
    end

    def range
      @from.send(@unit.to_sym)..to
    end

    def english
      "every #{every_what}"
    end

    def occurrences
  
    end

    def ocurrences_no_exceptions
  
    end

    def inf?
      @to == Inf && @limit.nil?
    end

    protected

      def eng_every
        #{@every} #{unit.as_word(@every > 1)}
      end

  end
  
end