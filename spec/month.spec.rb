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

describe Month, 'provides correct days' do

  it "should know number of days" do
    m(2000, 11).num_days.should == 30
    m(2000, 12).num_days.should == 31
    m(2001, 2 ).num_days.should == 28
    m(2000, 2 ).num_days.should == 29
  end
  
  def have_days(month, correct_num_days)
    month.day_factory = mock_day_factory = mock('day factory')
    received_nums = []
    expected_return = rand_int
    mock_day_factory.should_receive(:new) do |m, num|
      m.should == month
      received_nums << num
      expected_return
    end.exactly(correct_num_days).times
    month.days.uniq.should == [expected_return]
    received_nums[0].should == 1
    received_nums.sort.should == received_nums
  end
  
  it "should return an array of days" do
    # TODO: smell; no should here
    have_days m(2000, 11), 30
    have_days m(2000, 12), 31
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