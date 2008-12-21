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
    @paragraph = mock DSL::Paragraph.new
    @sentence = DSL::Sentence.new(@paragraph)
  end
  
  UNITS = UNIT_CLASSES.map { |c| [c.to_word(false), c.to_word(true)] }.flatten

  def with_units
    UNITS.each do |method|
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
      @sentence.send(m).should be_kind_of(DSL::AbstractClause)
    end
  end
  
  it "should create clauses that can refer back to original sentence" do
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
  
  it "should delegate 'serialize' to paragraph" do
    @paragraph.should_receive(:serialize).with(*args = [1,3,7]).once.
      and_return(return_from_paragraph_serialize = rand_int)
    @sentence.serialize(*args).should == return_from_paragraph_serialize
  end
  
  it "should delegate 'and' to paragraph" do
    @paragraph.should_receive(:and).once.
      and_return(return_from_paragraph_and = rand_int)
    @sentence.and.should == return_from_paragraph_and
  end
  
  it "should have a 'to_hash' form that traverses clauses" do
    @sentence.clauses << a = mock('clause a')
    @sentence.clauses << b = mock('clause b')
    @sentence.clauses << c = mock('clause c')
    returns = []
    [a,b,c].each do |clause|
      returns << (rval = rand_int)
      clause.should_receive(:to_hash).once.and_return(rval)
    end
    @sentence.to_hash[:clauses].should == returns
  end
  
end

describe DSL::AbstractClause do

  def mock_sentence
    out = mock(DSL::Sentence)
    out.stub!(:unit => 1)
    out
  end
  
  it "should copy the current unit from the sentence that created it" do
    # sentence is free to change the state of unit for the purpose of creating additional clauses
    sentence = mock_sentence
    sentence.should_receive(:unit).once.and_return(expected = rand_int)
    DSL::AbstractClause.new(sentence).unit.should == expected
  end
  
  it "should return the sentence with 'in'" do
    DSL::AbstractClause.new(sentence = mock_sentence).in.should == sentence
  end
  
  it "should delegate 'every' to sentence" do
    sentence = mock_sentence
    sentence.should_receive(:every).with(*args = [1,3,7]).once.
      and_return(return_from_sentence_every = rand_int)
    DSL::AbstractClause.new(sentence).every(*args).should == return_from_sentence_every
  end
  
  it "should delegate 'serialize' to sentence" do
    sentence = mock_sentence
    sentence.should_receive(:serialize).with(*args = [1,3,7]).once.
      and_return(return_from_sentence_serialize = rand_int)
    DSL::AbstractClause.new(sentence).serialize(*args).should == return_from_sentence_serialize
  end
  
end

describe 'paragraphs, sentences and clauses' do

  it "should integrate" do
    pending
    DSL::Paragraph.new.every.day.serialize.should == {
      :interval => 1, :unit => day, :clauses => [{:from => nil, :to => nil}]
    }
    #pending 'paragraph'
  end
  
end

describe DSL::Paragraph do

  it "should create new sentence and delegate call to that object with call to 'every'" do
    pending
  end

end