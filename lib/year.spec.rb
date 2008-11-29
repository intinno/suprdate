require 'core'
require 'year'

module YearHelpers
  
  def y_rand_int() (rand * 8000).round + 1600 end
  def y(x = 1600) Year.new(x) end
  
end

describe 'year is like an integer' do

  include YearHelpers

  it "should initialize with an integer" do
    3.times { y(ex = y_rand_int).to_i.should == ex }
  end
  
  it "should be comparable with years" do
    (y(ex = y_rand_int) == y(ex)).should == true
    (y(ex = y_rand_int) == y(ex + 1)).should == false
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

end

describe 'year comprised of months' do

  include YearHelpers
  
  before(:each) do
    @year = y
    @year.day_factory = @mock_day_factory = mock('day factory')
    @mock_month = mock('month')
    @year.month_factory = @month_factory = mock('month factory')
  end

  it "should return an array of months" do
    @month_factory.should_receive(:new).with(@year, an_instance_of(Integer)).
      exactly(NUM_MONTHS_IN_YEAR).times.and_return @mock_month
      
    @mock_month.should_receive(:day_factory=).with(@mock_day_factory).
      exactly(NUM_MONTHS_IN_YEAR).times.and_return(@mock_day_factory)
      
    months = @year.months
    months.nitems.should == NUM_MONTHS_IN_YEAR
    months[0].should == @mock_month
  end
  
  it "should provide individual months on demand" do
    @month_factory.should_receive(:new).with(@year, 1).once.and_return @mock_month
    @mock_month.should_receive(:day_factory=).with(@mock_day_factory).once.and_return(@mock_day_factory)
    @year.month(1).should == @mock_month
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

  include YearHelpers

  it "should not allow years before 1582 to be created" do
    lambda { y(300) }.should raise_error
    lambda { y(1500) }.should raise_error
    lambda { y(1600 - 100) }.should raise_error
    lambda { y(1600 + -100) }.should raise_error
    # these should be fine
    y(1582); y(1600)
  end

  it "should known when it's a leap year" do
    [1600, 1604, 1608, 1612, 2000, 2400, 2800].each do |year|
      y(year).leap?.should be_true
    end
    [1700, 1800, 1900, 2100, 2200, 2300, 2500, 2600, 2700, 2900, 3000].each do |year|
      y(year).leap?.should be_false
    end
  end

end

describe 'year comprised of days through months' do

  include YearHelpers

  NO_LEAP = false
  LEAP = true

  before(:each) do
    @year = y
    @expected = rand_int
    @year.month_factory = @month_factory = mock('month factory')
    @month = mock('month')
  end

  it "should return an array of days" do
    # days can only be created through months
    @month_factory.should_receive(:new).
      with(@year, an_instance_of(Integer)).
      exactly(NUM_MONTHS_IN_YEAR).times.and_return(@month)

    @month.should_receive(:day_factory=).with(nil).
      exactly(NUM_MONTHS_IN_YEAR).times.and_return(nil)
      
    @month.should_receive(:days).with(no_args).
      # each month creates only two days in this example...
      exactly(NUM_MONTHS_IN_YEAR).times.and_return Array.new(list_size = (rand * 5).round, @expected)
    
    days = @year.days
    # ...hence 24 days instead of 365
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