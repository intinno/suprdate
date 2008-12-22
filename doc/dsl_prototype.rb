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
    @from = nil
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
  
  alias :times :limit
  
end

DEFAULT_FREQ = 1

class Sentence
  
  attr_reader :clauses
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

# 2008-12-1
# 2008-12-10 
# 2008-12-19 
# 2008-12-28
# 2009-01-1
# 2009-01-10 
# 2009-01-19 
# 2009-01-28
# 2009-02-1
# 2009-02-10 
# 2009-02-19 
# 2009-02-28
pp event('I get a cold').every(9).days.in.months(:dec, :jan, :feb).done
# 2008-12-1
# 2008-12-10 
# 2008-12-19 
# 2008-12-28
# 2009-01-6
# 2009-01-15 
# 2009-01-24 
# 2009-02-02
# 2009-02-11
# 2009-02-20 
# 2009-02-29? 
pp event('I get a cold').every(9).days.in.months.from(:dec).to(:feb).done