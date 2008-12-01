describe 'month creation' do

  it "should work from an integer" do
    m(1).to_sym.should == :jan
    lambda { m(13) }.should raise_error
    lambda { m(0) }.should raise_error
  end

  it "should work from a symbol" do
    m(:jan).to_i.should == 1
    m(:feb).to_i.should == 2
  end
  
end

describe 'month comprised of days' do

  it "should know number of days" do
    m(11).num_days.should == 30
    m(12).num_days.should == 31
    m(2001, 2).num_days.should == 28
    m(2000, 2).num_days.should == 29
  end
  
  def init(month)
    @month = month
    @month.day_factory = @day_factory = mock('day factory')
    @expected = rand_int
  end
  
  # refactor candidate: ideally this should be a special rspec expectation
  def days(month, num_days)
    init month
    @day_factory.should_receive(:new).
      with(@month, an_instance_of(Integer)).
      exactly(num_days).times.and_return @expected
    day = @month.days
    day.nitems.should == num_days
    day[0].should == @expected
  end

  it "should return an array of days" do
    days m(11), 30
    days m(12), 31
  end
  
  it "should provide multiple individual days on demand" do
    init m(1)
    @day_factory.should_receive(:new).with(@month, 1).once.and_return 1
    @day_factory.should_receive(:new).with(@month, 3).once.and_return 2
    @day_factory.should_receive(:new).with(@month, 5).once.and_return 3
    @month.day(1, 3, 5).should == [1, 2, 3]
  end
  
  it "should provide multiple individual days on demand specified with negative offset" do
    init m(1)
    @day_factory.should_receive(:new).with(@month, 31).once.and_return :foo
    @day_factory.should_receive(:new).with(@month, 29).once.and_return :bar
    @month.day(-1, -3).should == [:foo, :bar]
  end
  
  it "should provide day 1 when no day value actually specified" do
    init m(1)
    @day_factory.should_receive(:new).with(@month, 1).once.and_return @expected
    @month.day.should == @expected
  end
  
end

describe 'month math and logic' do

  it "should be comparable" do
    (m(11) == m(11)).should == true
    (m(10) == m(11)).should == false
    (m(2001, 11) == m(2000, 11)).should == false
    (m(11) > m(12)).should == false
    (m(12) > m(11)).should == true
    (m(2001, 11) > m(2000, 11)).should == true
    (m(2000, 11) > m(2001, 11)).should == false
  end
  
  it "should be able to add with integers" do
    (m(11) + 1).should == m(12)
    (m(1999, 11) + 2).should == m(2000, 1)
  end
  
  it "should be able to subtract with integers " do
    (m(2001, 5) - 3).should == m(2001, 2)
    (m(2001, 1) - 1).should == m(2000, 12)
  end

  it "should hold state after arithmetic" do
    a = m(5)
    # day_factory is not used in any of these operations 
    # so it's ok to abuse it with a nonsense value
    a.day_factory = :foo
    b = a + 1
    b.day_factory.should == :foo
    b.object_id.should_not == a.object_id
  end
  
  it "should be rangeable" do
    (m(1)..m(4)).to_a.should == [m(1), m(2), m(3), m(4)]
  end
  
  it "should be able to get months since and until other months" do
    m(3).since(m(1)).should == 2
    m(2000, 1).since(m(1999, 1)).should == 12
    m(1).until(m(3)).should == 2
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