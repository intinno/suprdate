def rand_int(size = 80_000) (rand * size).round - size / 2 end

# lazy typist
alias :y :Year
alias :m :Month
alias :d :Day

describe 'disarray' do

  it "should return unaltered array if 2 or more elements" do
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

describe Builder do

  it "should build years" do
    year = Builder.new.year(expected = (rand * 100).round + 1700)
    year.should be_instance_of(Year)
    year.to_i.should == expected
    year.month_factory.should == Month
    year.day_factory.should == Day
    
    # reminds me to update the builder when I add this functionality
    year.week_definition.should == nil
  end
  
  it "should build months" do
    month = Builder.new.month(2008, expected = (rand * 11).round + 1)
    month.should be_instance_of(Month)
    month.to_i.should == expected
    month.day_factory.should == Day
    month.year.week_definition.should == nil
  end
  
  it "should build days" do
    day = Builder.new.day(2008, 1, expected = (rand * 30).round + 1)
    day.should be_instance_of(Day)
    day.year.week_definition.should == nil
    day.year.month_factory.should == Month
  end

end

describe 'every' do

  it "should filter lists by integer and symbol" do
    list = (1..10).to_a
    every(1, list).should == list
    every(2, list).should == [1, 3, 5, 7, 9]
    every(3, list).should == third = [1, 4, 7, 10]
    every(4, list).should == [1, 5, 9]
    every(:third, list).should == third
  end

end

describe 'exported builder methods' do
  
  it "should be defined" do
    respond_to?(:Year).should == true
    respond_to?(:Month).should == true
    respond_to?(:Day).should == true
    Day(2008, 10, 10).should == DEFAULT_BUILDER.day(2008, 10, 10)
  end

end

describe Inf do

  it "should return itself from unknown calls" do
    Inf.foo.should == Inf
    Inf.bar.should == Inf
  end
  
end