class Clause
  
  attr_accessor :unit, :return
  
  def every(freq = DEFAULT_FREQ)
    @return.every(freq)
  end
  
  def done
    @return.paragraph
  end
  
  def and
    done.repeats
  end
  
  alias :in :return
  alias :initialize :unit=
  
end

class ListClause < Clause
  
  attr_accessor :list
  
end

class RangeClause < Clause
  
  attr_accessor :freq
  
  def initialize(*args)
    super(*args)
    # replace with Today()
    @from = Time.now.send(@unit.to_sym)
    @to = Inf
    @limit = nil
  end
  
  def from(*from)
    return @from if from.empty?
    @from = from
    self
  end
  
  def to(*to)
    return @to if to.empty?
    @to = to
    self
  end
  
  def limit(limit = nil)
    return @limit if limit.nil?
    @limit = limit
    self
  end
  
  # TODO: except
  
  alias :times :limit
  
end

DEFAULT_FREQ = 1

class Sentence
  
  attr_reader :Clauses
  attr_accessor :paragraph
  
  def initialize(freq = DEFAULT_FREQ)
    @clauses = []
    @freq = freq
  end
  
  def add_clause(unit, list)
    if list.empty?
      clause = RangeClause.new(unit)
      clause.freq = @freq
    else
      clause = ListClause.new(unit)
      clause.list = list
    end
    clause.return = self
    @freq = DEFAULT_FREQ
    @clauses << clause
    clause
  end
  
  def years(*years)
    add_clause(:year, years)
  end
  
  def months(*months)
    add_clause(:month, months)
  end
  
  def days(*days)
    add_clause(:day, days)
  end
  
  def every(freq = DEFAULT_FREQ)
    @freq = freq
    self
  end
  
  alias :year :years
  alias :month :months
  alias :day :days
  #alias :and :paragraph
  
end

module Inf; end

require 'rubygems'
require 'pp'

def event(title)
  Paragraph.new(title)
end

class Paragraph
  
  def initialize(title)
    @title = title
    @sentences = []
  end
  
  def repeats(*args)
    @sentences << sentence = Sentence.new(*args)
    sentence.paragraph = self
    sentence
  end
  
  alias :every :repeats
end

pp event('Christmas').repeats.day(25).in.month(12).every.year.done
puts
pp event('Nicole cooks').every(3).days.and.day(25).in.month(12).every.year.done
puts
# TODO: from shouldn't be required here, should be implied by the presence of less specific clause
pp event('I get a cold').every(10).days.from(1).in.months(:dec, :jan, :feb).done