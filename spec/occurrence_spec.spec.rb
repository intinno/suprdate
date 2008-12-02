# Some terminology
#   clause: refers to a method call that is a part of a sentence
#     e.g. in every.year.from(2000) => "every", "year" and "from" are all clauses
#   sentence: a series of clauses methods that state something, delimited with and
#     e.g. in every.year.from(2000).and.every(2).months.from(2001)
#       "every.year.from(2000)" is a sentence and so is "every(2).months.from(2001)"
#   unit: Year, Month, Day are all different "units" of time

describe OccurrenceSpec do

  def o(*args)
    OccurrenceSpec.new *args
  end

  it "should use the builder date method for 'to' and 'from' clauses" do
    o = o() # man with one ear
    o.builder.should_receive(:date).with(to = rand_int).once
    o.builder.should_receive(:date).with(from = rand_int).once
    o.to(to).from(from)
  end

  # A "to" or "from" clause will accept 1, 2 or 3 args.
  # This provides all the possible permutations [1,1],[1,2],[1,3],[2,1] etc.
  def each_to_from_clause_permutation
    Builder::NUM_PARTS_RANGE.each do |from_num_parts|
      Builder::NUM_PARTS_RANGE.each do |to_num_parts|
        yield date_parts(from_num_parts), date_parts(to_num_parts)
      end
    end
  end
  
  it "should create range with specified unit regardless of the from unit" do
    each_to_from_clause_permutation do |to, from|
      [Year, Month, Day].each do |unit|
        o = o('Satisfied chicken')
        range = o.every.__send__(unit.to_sym).from(*from).to(*to).last_range
        range.first.class.should == unit
        range.last.should == o.builder.date(*to)
      end
    end
  end
  
  it "should substitute Inf when to clause is omitted" do
    range = o.every.month.from(2008).last_range
    range.last.should == Inf
  end
  
  it "should filter the results by frequency if one is provided in the 'every' clause" do
    o = o()
    a = o.every(2).months.from(2008).to(2008, 05).occurrences.map { |months| months.to_s }.
      should == %w{2008-01 2008-03 2008-05}
    o.sentences.nitems.should == 1
  end
  
  it "should allow multiple sentences to be delimited and stored with 'and'" do
    o = o()
    o.every.year.from(2000).to(2003).and.every.year.from(2010).to(2020)
    o.sentences.nitems.should == 2
  end
  
end