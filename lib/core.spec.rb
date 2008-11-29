def rand_int(size = 80_000) (rand * size).round - size / 2 end

describe 'disarray' do

  it "should return an array if 2 or more elements" do
    disarray(array = Array.new(2)).should == array
    disarray(array = Array.new(5)).should == array
    disarray(array = Array.new(10)).should == array
  end
  
  it "should return first element of a single element array" do
    disarray([:foo]).should == :foo
    disarray([80081355]).should == 80081355
  end

end

describe 'self building integration' do

  require 'year'
  require 'month'
  require 'day'

  it "should allow years to build months and month to build days" do
    
    year = Year.new(2000)
    year.month_factory = mock_month_factory = mock('month factory')
    year.day_factory = mock_day_factory = mock('day factory')
    
    mock_month_factory.should_receive(:new).once.
      with(year, month_value = rand_int).and_return(mock_month = mock('month'))

    mock_month.should_receive(:day_factory=).once.
      with(mock_day_factory).and_return(mock_day_factory)
      
    mock_month.should_receive(:day).once.
      with(day_value = rand_int).and_return(mock_day = rand_int)
      
    year.month(month_value).day(day_value).should == mock_day
    
  end
  
  it "should allow months to build days" do
    
    month = Month.new(Year.new(2008), 10)
    month.day_factory = mock_day_factory = mock('day factory')
    
    mock_day_factory.should_receive(:new).once.
      with(month, day_value = rand_int).and_return(mock_day = rand_int)
    
    month.day(day_value).should == mock_day
    
  end

end