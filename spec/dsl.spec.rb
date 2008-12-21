describe DSL, 'event' do

  it "should create a paragraph" do
    DSL.event.should be_kind_of(DSL::Paragraph)
  end
  
end

# TODO: duplication of all the delegation checks
# TODO: duplication of traversal in sentence for clauses and paragraph for sentences
# TODO: use instance_variables to determine that to_hash is complete

describe DSL::Sentence do

  UNITS = UNIT_CLASSES.map { |c| [c.to_word(false), c.to_word(true)] }.flatten
  
  before(:each) do
    reset
  end

  def reset
    @paragraph = mock DSL::Paragraph.new
    @sentence = DSL::Sentence.new(@paragraph)
  end

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
    pending 'clause creation can be mocked'
    with_units do |m|
      args = [2000, 2004, 2008]
      clause = @sentence.send(m, *args)
      clause.should be_kind_of(DSL::ListClause)
      # clause.should_receive(:polarity=).once.with(:inclusion)
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
    rvs = []
    [a,b,c].each do |clause|
      rvs << (rv = rand_int)
      clause.should_receive(:to_hash).once.and_return(rv)
    end
    @sentence.to_hash[:clauses].should == rvs
  end
  
end

describe DSL::AbstractClause do

  def mock_sentence
    rv = mock(DSL::Sentence)
    rv.stub!(:unit => 1)
    rv
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

describe 'paragraphs, sentences and clauses integrated' do

  it "should serialize" do
    # traverses up from clause, through sentence, to paragraph and then back down 
    # using to_hash
    DSL::Paragraph.new('foo').every.day.serialize.should == {
      :title => 'foo', :sentences => [
        {:interval => 1, :clauses => [{:unit => Day, :type => :range, :from => nil, :to => nil, :limit => nil}]}
      ]
    }
  end
  
end

describe DSL::Paragraph do

  before(:each) do
    @paragraph = DSL::Paragraph.new
  end

  it "should create new sentence and delegate call to that object with call to 'every'" do
    @paragraph.sentence_factory.should_receive(:new).with(@paragraph).once.and_return(sentence = mock('sentence'))
    sentence.should_receive(:every).with(interval = rand_int).and_return(sentence_return = rand_int)
    @paragraph.every(interval).should == sentence_return
    @paragraph.sentences.should == [sentence]
  end

  it "should have a 'to_hash' form that traverses clauses" do
    @paragraph.sentences << a = mock('sentence a')
    @paragraph.sentences << b = mock('sentence b')
    @paragraph.sentences << c = mock('sentence c')
    rvs = []
    [a,b,c].each do |clause|
      rvs << (rv = rand_int)
      clause.should_receive(:to_hash).once.and_return(rv)
    end
    @paragraph.to_hash[:sentences].should == rvs
  end
  

end