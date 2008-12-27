describe 'year is like an integer' do

  it "should initialize with an integer" do
    3.times { y(ex = y_rand_int).to_i.should == ex }
  end
  
  it "should be comparable with years" do
    (y(ex = y_rand_int) == y(ex)).should == true
    (y(ex = y_rand_int) == y(ex + 1)).should == false
    (y(2001) > y(2000)).should == true
    (y(2000) > y(2000)).should == false
    (y(2000) < y(2001)).should == true
    (y(2000) < y(2000)).should == false
  end
  
  it "should know the successive year" do
    y(2000).succ.should == y(2001)
    (y(2000) .. y(2003)).to_a.should == [y(2000), y(2001), y(2002), y(2003)]
  end
  
  it "should respond to addition with an integer" do
    (y(a = y_rand_int) + b = y_rand_int).should == y(a + b)
  end
  
  it "should respond to subtraction with an integer" do
    (y(a = y_rand_int) - b = 10).should == y(a - b)
  end
  
  it "should hold state after arithmetic" do
    a = Year.new(2000)
    # month_factory is not used in any of these operations 
    # so it's ok to abuse it with a nonsense value
    a.month_factory = :foo
    b = a + 1
    b.month_factory.should == :foo
    b.object_id.should_not == a.object_id
  end
  
  it "should be able to get years since and until other years" do
    y(2005).since(y(2000)).should == 5
    y(2000).until(y(2005)).should == 5
  end
  
  it "should not permit you to get years since or until months or days" do
    lambda { y.since(d) }.should raise_error
    lambda { y.until(d) }.should raise_error
    lambda { y.since(m) }.should raise_error
    lambda { y.until(m) }.should raise_error
  end

end

describe 'year comprised of months' do

  before(:each) do
    @year = y(2000)
    @year.day_factory = @mock_day_factory = mock('day factory')
    @mock_month = mock('month')
    @year.month_factory = @month_factory = mock('month factory')
  end

  it "should return an array of months" do
    nums = []
    @month_factory.should_receive(:new) do |year, n|
      year.should == @year
      nums << n
      @mock_month
    end.exactly(NUM_MONTHS_IN_YEAR).times
      
    @mock_month.should_receive(:day_factory=).with(@mock_day_factory).
      exactly(NUM_MONTHS_IN_YEAR).times.and_return(@mock_day_factory)
      
    @year.months[0].should == @mock_month
    nums.sort.should == nums
    nums[0].should == 1
  end
  
  it "should provide individual months on demand" do
    @month_factory.should_receive(:new).with(@year, 1).once.and_return @mock_month
    @mock_month.should_receive(:day_factory=).with(@mock_day_factory).once.and_return(@mock_day_factory)
    @year.month(1).should == @mock_month
  end
  
  it "should provide month 1 when no month value actually specified" do
    @month_factory.should_receive(:new).with(@year, 1).once.and_return @mock_month
    @mock_month.should_receive(:day_factory=).with(@mock_day_factory).once.and_return(@mock_day_factory)
    @year.month.should == @mock_month
  end
  
  it "should provide multiple individual months on demand" do
    @month_factory.should_receive(:new).with(@year, 1).once.and_return @mock_month
    @month_factory.should_receive(:new).with(@year, 3).once.and_return @mock_month
    @month_factory.should_receive(:new).with(@year, 5).once.and_return @mock_month
    @mock_month.should_receive(:day_factory=).with(@mock_day_factory).
      exactly(3).times.and_return(@mock_day_factory)
    @year.month(1, 3, 5).should == Array.new(3, @mock_month)
  end
  
end

describe 'year misc' do

  it "should not allow years before 1582 to be created" do
    lambda { y(300) }.should raise_error(DateConstructionError)
    lambda { y(1500) }.should raise_error(DateConstructionError)
    lambda { y(1582); y(1600) }.should_not raise_error
  end

  it "should known when it's a leap year" do
    # http://en.wikipedia.org/wiki/Leap_year#Gregorian_calendar
    [1600, 1604, 1608, 1612, 2000, 2400, 2800].each do |year|
      y(year).leap?.should be_true
    end
    [1700, 1800, 1900, 2100, 2200, 2300, 2500, 2600, 2700, 2900, 3000].each do |year|
      y(year).leap?.should be_false
    end
  end

end

describe 'year comprised of days (via months)' do

  NO_LEAP = false
  LEAP = true

  before(:each) do
    @year = y(2000)
    @expected = rand_int
    @year.month_factory = @month_factory = mock('month factory')
    @month = mock('month')
  end

  it "should return an array of days" do
    # days can only be created through months
    @month_factory.should_receive(:new).
      with(@year, an_instance_of(Integer)).
      exactly(NUM_MONTHS_IN_YEAR).times.and_return(@month)

    @month.should_receive(:day_factory=).with(@year.day_factory).
      exactly(NUM_MONTHS_IN_YEAR).times.and_return(@year.day_factory)
      
    @month.should_receive(:days).with(no_args).
      # each month creates only two days in this example...
      exactly(NUM_MONTHS_IN_YEAR).times.and_return Array.new(list_size = (rand * 6).round + 1, @expected)
    
    days = @year.days
    days.nitems.should == list_size * NUM_MONTHS_IN_YEAR
    days[0].should == @expected
  end

end

describe 'year copies' do

  it "should hold state" do
    a = Year.new(2000)
    a.month_factory = :foo
    b= a.new(2001)
    b.object_id.should_not == a.object_id
    b.month_factory.should == a.month_factory
  end

end