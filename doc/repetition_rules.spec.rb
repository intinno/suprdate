 s# this file is obsolete and has been retained for reference purposes only 

describe RepetitionRules do

  it "should use the builder date method for 'to' and 'from' clauses" do
    r = r() # man with one ear
    r.builder.should_receive(:date).with(to = rand_int).once
    r.builder.should_receive(:date).with(from = rand_int).once
    r.to(to).from(from)
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
      UNIT_CLASSES.each do |unit|
        r = r('Satisfied chicken')
        range = r.every.__send__(unit.to_sym).from(*from).to(*to).last_range
        range.first.class.should == unit
        range.last.should == r.builder.date(*to)
      end
    end
  end
  
  it "should substitute Inf when to clause is omitted" do
    range = r.every.month.from(2008).last_range
    range.last.should == Inf
  end
  
  it "should filter the results by frequency if one is provided in the 'every' clause" do
    r = r()
    r.every(2).months.from(2008).to(2008, 05).occurrences.map { |months| months.to_s }.
      should == %w{2008-01 2008-03 2008-05}
    r.sentences.nitems.should == 1
  end
  
  it "should allow multiple sentences to be delimited and stored with 'and'" do
    r = r()
    r.every.year.from(2000).to(2003).and.every.year.from(2010).to(2020)
    r.sentences.nitems.should == 2
  end
  
  it "should raise if you omit required clauses" do
    lambda { r.and }.should raise_error 'Chunky bacon sentence missing unit specification clause such as year, month or day'
    lambda { r.year.and }.should raise_error 'Chunky bacon sentence missing required clause: "from"'
  end
  
  it "should produce all the repetitions from all the sentences in the order they were specified" do
    pending
  end
  
  it "should disallow call to repetitions without a block if holding a sentence ending in Inf" do
    pending
  end
  
  it "should handle blocks for 'to' that end when breaking true" do
    pending
  end
  
end