def mock_sentence
  rval = mock DSL::Sentence
  rval.stub!(:interval => DSL::CONTINUOUS, :unit => nil, :every => rval)
  rval
end

describe DSL::ClauseFactory do

  before(:each) do
    @sentence = mock_sentence
    @cf = DSL::ClauseFactory.new
  end

  it "should create a list clause if list has length" do
    clause = @cf.make(@sentence, list = [1,2,3])
    clause.should be_instance_of(DSL::ListClause)
    clause.list.should == list
  end
  
  it "should create a range clause if list is empty" do
    clause = @cf.make(@sentence, [])
    clause.should be_instance_of(DSL::RangeClause)
  end
  
  it "should create clauses that can refer back to original @sentence" do
    clause = @cf.make(@sentence, [])
    clause.sentence.should == @sentence
  end

end

describe DSL::Sentence do

  UNITS_AS_SYM = UNITS.map { |c| [c.name_singular, c.name_plural] }.flatten
  
  before(:each) do
    reset
  end

  def reset
    @paragraph = mock DSL::Paragraph.new
    @sentence = DSL::Sentence.new(@paragraph)
  end

  def with_units
    UNITS_AS_SYM.each do |method|
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
  
  it "should use ClauseFactory for clause creation" do
    with_units do |m|
      @sentence.clause_factory = mcf = mock('clause factory')
      mcf.should_receive(:make).with(@sentence, list = Array.new(rand_between(1..5))).once.and_return(rval = rand_int)
      @sentence.send(m, *list).should == rval
    end
  end
  
  it "should have a 'to_hash' form that traverses including and excluding clauses" do
    @sentence.including << a = mock('clause a')
    @sentence.excluding << b = mock('clause b')
    a.should_receive(:to_hash).once.and_return(expected_a = rand_int)
    b.should_receive(:to_hash).once.and_return(expected_b = rand_int)
    hash = @sentence.to_hash
    hash[:including].should == [expected_a]
    hash[:excluding].should == [expected_b]
  end
  
end

# Pure interaction spec
describe 'abstract clause', :shared => true do

  before(:each) do
    @sentence = mock_sentence
    @clause_class = DSL::Clause
  end
  
  it "should copy the current unit from the @sentence that created it" do
    @sentence.should_receive(:unit).once.and_return(expected = rand_int)
    @clause_class.new(@sentence).unit.should == expected
  end
  
  it "should return the @sentence with 'in'" do
    @clause_class.new(@sentence).in.should == @sentence
  end
  
end

describe DSL::RangeClause do

  it_should_behave_like 'abstract clause'

  before(:each) do
    @sentence = mock_sentence
    @clause_class = DSL::RangeClause
  end
  
  it "should copy the current interval from the @sentence that created it" do
    @sentence.should_receive(:interval).once.and_return(expected = rand_int)
    @clause_class.new(@sentence).interval.should == expected
  end
  
end

describe DSL::ListClause do

  it_should_behave_like 'abstract clause'
  
  before(:each) do
    @sentence = mock_sentence
    @clause_class = DSL::ListClause
  end

end

describe DSL, 'elements integrated' do

  it "should traverses up from clause, through sentence, to paragraph and then back down using to_hash" do
    Event().serialize[:sentences].should_not be_nil
    Event().every.serialize[:sentences][0][:including].should_not be_nil
    Event().every.day.serialize[:sentences][0][:including][0].should_not be_nil
  end
  
  it "should allowed several sentences to be chained with and" do
    s = Event().every(2).days.in.month(:jan).and.every(3).days.in.month(:feb).serialize
    s[:sentences].nitems.should == 2
    s[:sentences][0][:including].nitems.should == 2
  end
  
  it "should prevent intervals being set on list clauses" do
    lambda { Event().every(2).days(1, 3, 5) }.should raise_error(DSL::ExpressionError)
  end
  
  it "should support except and include" do
    sen = Event().every
    serialization = sen.serialize[:sentences][0]
    serialization[:including].nitems.should == 0
    serialization[:excluding].nitems.should == 0
    serialization = sen.except.include.every(3).days.except.days(:wed).serialize[:sentences][0]
    serialization[:including].nitems.should == 1
    serialization[:excluding].nitems.should == 1
  end
  
  def mock_english_serializer_factory(expected)
    (es = mock('eng serializer')).should_receive(:convert).with(an_instance_of(Hash)).and_return(expected)
    (esf = mock('eng serializer factory')).should_receive(:new).with(no_args).and_return(es)
    esf
  end
  
  it "should provide to_english which uses SerializationToEnglish#description" do
    {:paragraph => Event().paragraph, 
     :sentence  => Event(), 
     :clause    => Event().every.day}.values.each do |dsl_element|
      dsl_element.english_serializer_factory = mock_english_serializer_factory(expected = rand_int)
      dsl_element.to_english.should == expected
    end
  end
  
  it "should not permit units to be contained within the same unit" do
    lambda { Event().every.day.in.day }.should raise_error(DSL::ExpressionError)
    lambda { Event().every.month.in.month }.should raise_error(DSL::ExpressionError)
    lambda { Event().every.year.in.year }.should raise_error(DSL::ExpressionError)
    pending 'Missing weeks' if defined? Week
  end
  
  it "should not permit units to be contained within the smaller unit" do
    lambda { Event().every.month.in.day }.should raise_error(DSL::ExpressionError)
    lambda { Event().every.year.in.day }.should raise_error(DSL::ExpressionError)
    lambda { Event().every.year.in.month }.should raise_error(DSL::ExpressionError)
    pending 'Missing weeks' if defined? Week
  end
  
  it "should not permit incomplete things" do
    lambda { Event().every.day.in.month }.should raise_error(DSL::ExpressionFragment)
    lambda { Event().every.month.in.year }.should raise_error(DSL::ExpressionFragment)
    lambda { Event().every.day.in.year }.should raise_error(DSL::ExpressionFragment)
    lambda { Event().every.day.in.month(:jan).in.year }.should raise_error(DSL::ExpressionFragment)
  end
  
end

describe DSL::Paragraph do

  before(:each) do
    @paragraph = DSL::Paragraph.new
  end

  it "should create new sentence and delegate call to that object with call to 'every'" do
    @paragraph.sentence_factory.should_receive(:new).with(@paragraph).once.and_return(sentence = mock_sentence)
    sentence.should_receive(:every).with(interval = rand_int).and_return(sentence_return = rand_int)
    @paragraph.every(interval).should == sentence_return
    @paragraph.sentences.should == [sentence]
  end

  it "should have a 'to_hash' form that traverses clauses" do
    @paragraph.sentences << a = mock('sentence a')
    @paragraph.sentences << b = mock('sentence b')
    @paragraph.sentences << c = mock('sentence c')
    rvals = []
    [a,b,c].each do |clause|
      rvals << (rval = rand_int)
      clause.should_receive(:to_hash).once.and_return(rval)
    end
    @paragraph.to_hash[:sentences].should == rvals
  end
  
end

describe 'chain_attr_accessor' do
  
  extend DSL::ChainAttrAccessor

  chain_attr_accessor :foo
  
  it "should return @foo if no arguments and leave @foo unaltered" do
    @foo = rand_int
    foo().should == @foo
  end
  
  it "should set @foo to the argument list if list has length and return self" do
    @foo = nil
    args = Array.new(rand_between(1..5)) { rand }
    foo(*args).should == self
    @foo.should == args
  end

end

describe DSL::SerializationToEnglish, 'integrated with the DSL serialization' do

  it "should serialize totally empty paragraphs" do
    Event('Foo').to_english.should == 'Foo never happens'
  end
  
  it "should serialize unlimited ranges" do
    Event('Foo').every.day.to_english.should == 'Foo happens every day'
    Event('Foo').every.month.to_english.should == 'Foo happens every month'
    Event('Foo').every.year.to_english.should == 'Foo happens every year'
  end
  
  it "should serialize intervalled ranges" do
    Event('Foo').every(2).days.to_english.should == 'Foo happens every 2 days'
    Event('Foo').every(4).day.to_english.should == 'Foo happens every 4 days'
    Event('Foo').every(9).month.to_english.should == 'Foo happens every 9 months'
  end
  
  it "should serialize multiple clauses" do
    pending 'Once invalid serializations cannot occur'
    Event('foo').every.day.in.month(:jan).to_english.should == 'Foo happens every day in January'
    Event('foo').every(9).days.in.month(:jan).to_english.should == 'Foo happens every 9 days in January, starting from the 1st'
    Event('foo').every(2).days.in.year(2000).to_english.should == 'Foo happens every 2 days in 2000, starting from January 1st'
  end

end

describe DSL::SerializationClauseHelper do

  def subject(hash)
    hash.extend(DSL::SerializationClauseHelper)
    hash
  end
  
  it "should have interval when [:interval] is greater than 1" do
    subject(:interval => 1).has_interval.should == false
    subject(:interval => 2).has_interval.should == true
  end
  
  it "should provide a unit name in plural or singular depending on interval also" do
    (mock = mock('unit')).should_receive(:name_singular).once.and_return(expected = rand_int)
    subject(:interval => 1, :unit => mock).unit_name == expected
    
    (mock = mock('unit')).should_receive(:name_plural).once.and_return(expected = rand_int)
    subject(:interval => 2, :unit => mock).unit_name == expected
  end

end