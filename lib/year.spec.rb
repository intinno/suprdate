require 'core'
require 'year'

module YearHelpers
  
  def rand_int(size = 80_000) (rand * size).round - size / 2 end
  def y_rand_int() (rand * 8000).round + 1600 end
  def y(x = 1600) Year.new(x) end
  
end

describe 'year is an integer' do

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
  
end

describe 'year comprised of months' do

  include YearHelpers
  
  before(:each) do
    @year = y
    @expected = rand_int
    @year.month_class = @month_class = mock('month class')
  end

  it "should return an array of months" do
    @month_class.should_receive(:new).
      with(@year, an_instance_of(Integer)).
      exactly(12).times.and_return @expected
    months = @year.months
    months.nitems.should == 12
    months[0].should == @expected
  end
  
  it "should provide individual months on demand" do
    @month_class.should_receive(:new).with(@year, 1).once.and_return @expected
    @year.month(1).should == @expected
  end
  
  it "should provide multiple individual months on demand" do
    @month_class.should_receive(:new).with(@year, 1).once.and_return 1
    @month_class.should_receive(:new).with(@year, 3).once.and_return 2
    @month_class.should_receive(:new).with(@year, 5).once.and_return 3
    @year.month(1, 3, 5).should == [1, 2, 3]
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
    @year.month_class = @month_class = mock('month class')
    @month = mock('month')
  end

  it "should return an array of days" do
    # days can only be created through months
    @month_class.should_receive(:new).
      with(@year, an_instance_of(Integer)).
      exactly(12).times.and_return(@month)
    
    @month.should_receive(:days).with(no_args).
      # each month creates only two days in this example...
      exactly(12).times.and_return [@expected, @expected]
    
    days = @year.days
    # ...hence 24 days instead of 365
    days.nitems.should == 24
    days[0].should == @expected
  end

end