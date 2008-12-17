describe DSL, 'event' do

  it "should create a paragraph" do
    DSL.event.should be_kind_of(DSL::Paragraph)
  end
  
end

describe DSL::Sentence do

  before(:each) do
    reset
  end

  def reset
    @sentence = DSL::Sentence.new
  end

  def with_units
    %w{years year months month day days}.each do |method|
      reset
      yield method
    end
  end
  
  it "should define repeating interval with 'every'" do
    @sentence.interval.should == 1 # default
    # also implies that every returns @sentence
    @sentence.every.interval.should == 1
    @sentence.every(expected = rand_int).interval.should == expected
  end
  
  it "has unit methods that create a clause" do
    with_units do |m|
      @sentence.send(m).should be_kind_of(DSL::Clause)
    end
  end
  
  it "should create clauses that refer back to original sentence" do
    with_units do |m|
      clause = @sentence.send(m)
      @sentence.clauses.should == [clause]
      clause.sentence.should == @sentence
    end
  end
  
  it "should create a range clause if no arguments specified with the unit" do
    with_units do |m|
      @sentence.send(m).should be_kind_of(DSL::RangeClause)
    end
  end
  
  it "should create a list clause if arguments are specified with the unit and hand on those 
  arguments to the clause" do
    with_units do |m|
      args = [2000, 2004, 2008]
      clause = @sentence.send(m, *args)
      clause.should be_kind_of(DSL::ListClause)
      clause.list.should == args
    end
  end
  
end

describe DSL::Clause do

  it "should copy the current unit from the sentence that created it" do
    # sentence is free to change the state of unit for the purpose of creating additional clauses
    sentence = mock 'sentence'
    sentence.should_receive(:unit).once.and_return(expected = rand_int)
    DSL::Clause.new(sentence).unit.should == expected
  end

end

describe DSL::Sentence, 'integration' do

  before(:each) do
    @sentence = DSL::Sentence.new
  end

  it "should provide all days" do
    pending
    range = sentence.every.day.range
    range.first.should == today
    range.last.should be_kind_of(Inf)
  end
  
end

describe DSL::Paragraph do

  

end