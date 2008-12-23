describe Month, 'creation' do

  it "should work from an integer" do
    m(2000, 1).to_sym.should == :jan
    lambda { m(2000, 13) }.should raise_error
    lambda { m(2000, 0) }.should raise_error
  end

  it "should work from a symbol" do
    m(2000, :jan).to_i.should == 1
    m(2000, :feb).to_i.should == 2
  end
  
end

describe Month, 'provides days correctly' do

  def have_num_days(expected)
    simple_matcher('have correct number of days') do |given, matcher|
      matcher.failure_message = "expected #{given} to have #{expected} number of days"
      given.num_days == expected && given.days.nitems == expected
    end
  end

  it "should know number of days" do
    m(2000, 11).should have_num_days(30)
    m(2000, 12).should have_num_days(31)
    m(2001, 2 ).should have_num_days(28)
    m(2000, 2 ).should have_num_days(29)
  end
  
  it "should create days with day factory" do
    month = m(2000, 1)
    month.day_factory = mock_day_factory = mock('day factory')
    mock_day_factory.should_receive(:new).with(month, an_instance_of(Integer)).at_least(:once)
    month.days
  end
  
  it "should return days in correct order" do
    # this is testing more than it claims. Should really be done with a mock day_factory and mock days
    # but, you know, it's not doing anyone any harm
    day_numbers = m(2000, 1).days.map { |day| day.value }
    day_numbers.sort.should == day_numbers 
  end
  
end

describe Month, 'provides individual days' do
  
  before(:each) do
    @month = m(2000, 1)
    @month.day_factory = @mock_day_factory = mock('day factory')
  end

  it "should provide multiple individual days on demand" do
    @mock_day_factory.should_receive(:new).with(@month, 1).once.and_return 1
    @mock_day_factory.should_receive(:new).with(@month, 3).once.and_return 2
    @mock_day_factory.should_receive(:new).with(@month, 5).once.and_return 3
    @month.day(1, 3, 5).should == [1, 2, 3]
  end
  
  it "should provide multiple individual days on demand specified with negative offset" do
    @mock_day_factory.should_receive(:new).with(@month, 31).once.and_return :foo
    @mock_day_factory.should_receive(:new).with(@month, 29).once.and_return :bar
    @month.day(-1, -3).should == [:foo, :bar]
  end
  
  it "should provide day 1 when no day value actually specified" do
    @mock_day_factory.should_receive(:new).with(@month, 1).once.and_return(expected = rand_int)
    @month.day.should == expected
  end
  
end

describe Month, 'math and logic' do

  it "should be comparable" do
    (m(2000, 11) == m(2000, 11)).should == true
    (m(2000, 10) == m(2000, 11)).should == false
    (m(2001, 11) == m(2000, 11)).should == false
    (m(2000, 11)  > m(2000, 12)).should == false
    (m(2000, 12)  > m(2000, 11)).should == true
    (m(2001, 11)  > m(2000, 11)).should == true
    (m(2000, 11)  > m(2001, 11)).should == false
  end
  
  it "should be able to add with integers" do
    (m(2000, 11) + 1).should == m(2000, 12)
    (m(1999, 11) + 2).should == m(2000, 1)
  end
  
  it "should be able to subtract with integers " do
    (m(2001, 5) - 3).should == m(2001, 2)
    (m(2001, 1) - 1).should == m(2000, 12)
  end

  it "should hold state after arithmetic" do
    a = m(2000, 5)
    # day_factory is not used in any of these operations 
    # so it's ok to abuse it with a nonsense value
    a.day_factory = :foo
    b = a + 1
    b.day_factory.should == :foo
    b.object_id.should_not == a.object_id
  end
  
  it "should be rangeable" do
    (m(2000, 1)..m(2000, 4)).to_a.should == [m(2000, 1), m(2000, 2), m(2000, 3), m(2000, 4)]
  end
  
  it "should be able to get months since and until other months" do
    m(2000, 3).since(m(2000, 1)).should == 2
    m(2000, 1).since(m(1999, 1)).should == 12
    m(2000, 1).until(m(2000, 3)).should == 2
    m(1999, 1).until(m(2000, 1)).should == 12
  end

  it "should be able to get months since and until years" do
    m(2000, 3).since(y(2000)).should == 2
    m(2000, 10).until(y(2001)).should == 3
  end
  
  it "should not permit you to get months since or until days" do
    lambda { m.since(d) }.should raise_error
    lambda { m.until(d) }.should raise_error
  end

end