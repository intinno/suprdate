def mock_sentence
  rval = mock DSL::Sentence
  rval.stub!(:interval => nil, :unit => nil)
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

  UNITS = UNIT_CLASSES.map { |c| [c.name_singular, c.name_plural] }.flatten
  
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
  
  it "should use ClauseFactory for clause creation" do
    with_units do |m|
      @sentence.clause_factory = mcf = mock('clause factory')
      mcf.should_receive(:make).with(@sentence, list = Array.new(rand_between(1..5))).once.and_return(rval = rand_int)
      @sentence.send(m, *list).should == rval
    end
  end
  
  it "should have a 'to_hash' form that traverses clauses" do
    @sentence.clauses << a = mock('clause a')
    @sentence.clauses << b = mock('clause b')
    @sentence.clauses << c = mock('clause c')
    rvals = []
    [a,b,c].each do |clause|
      rvals << (rval = rand_int)
      clause.should_receive(:to_hash).once.and_return(rval)
    end
    @sentence.to_hash[:clauses].should == rvals
  end
  
end

# Pure interaction spec
describe 'abstract clause', :shared => true do

  before(:each) do
    @sentence = mock_sentence
    @clause_class = DSL::AbstractClause
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

  it_should_behave_like('abstract clause')

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

  it_should_behave_like('abstract clause')
  
  before(:each) do
    @sentence = mock_sentence
    @clause_class = DSL::ListClause
  end

end

describe 'paragraphs, sentences and clauses integrated' do

  it "should traverses up from clause, through sentence, to paragraph and then back down using to_hash" do
    Event('foo').serialize.should == {:title => 'foo', :sentences => []}
    Event('foo').every.serialize.should == {:title => 'foo', :sentences => [{:clauses => []}]}
    Event('foo').every.day.serialize.should == {
      :title => 'foo', :sentences => [
        {:clauses => [{:interval => 1, :unit => Day, :type => :range, :from => nil, :to => nil, :limit => nil}]}
      ]
    }
  end
  
  it "should allowed several sentences to be chained with and" do
    Event('foo').every(2).days.in.month(:jan).and.every(3).days.in.month(:feb).serialize.should == {
      :title => 'foo', :sentences => [
        {:clauses => [
          {:interval => 2, :unit => Day, :type => :range, :from => nil, :to => nil, :limit => nil},
          {:unit => Month, :type => :list, :list => [:jan]}
        ]},
        {:clauses => [
          {:interval => 3, :unit => Day, :type => :range, :from => nil, :to => nil, :limit => nil},
          {:unit => Month, :type => :list, :list => [:feb]}
        ]}
      ]
    }
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