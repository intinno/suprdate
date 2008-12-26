describe Suprdate, :every do

  it "should filter lists by integer and symbol" do
    list = (1..10).to_a
    every(1, list).should == list
    every(2, list).should == [1, 3, 5, 7, 9]
    every(3, list).should == third = [1, 4, 7, 10]
    every(4, list).should == [1, 5, 9]
    every(:third, list).should == third
  end
  
  it "should return the whole list if a block is provided" do
    i = 0
    every(2, [1,2]) { |x| x.should == 1; i+= 1 }.should == [1,2]
    i.should == 1
  end
  
  it "should raise if using an unknown symbol" do
    lambda { every(:keith, [1,2,3]) }.should raise_error('Specified symbol does not specify a known frequency')
  end
  
end

describe Suprdate, :disarray do

  it "should return unaltered array if 2 or more elements" do
    Utility::disarray(array = Array.new(2)).should == array
    Utility::disarray(array = Array.new(5)).should == array
    Utility::disarray(array = Array.new(10)).should == array
  end
  
  it "should return first element of a single element array" do
    Utility::disarray([:foo]).should == :foo
    Utility::disarray([80081355]).should == 80081355
  end

end

describe Utility::CleanName do

  module FooNamespace
    class Monkey
      extend Utility::CleanName
    end
  end  
  
  it "should provide short version of the original" do
    FooNamespace::Monkey.name.should == 'FooNamespace::Monkey'
    FooNamespace::Monkey.name_singular.should == 'monkey'
    FooNamespace::Monkey.to_sym.should == 'monkey'.to_sym
    FooNamespace::Monkey.name_plural.should == 'monkeys'
  end

end

describe 'self building integration' do

  it "should allow years to build months and months to build days" do
    
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
      with(month, day_value = rand_int.abs).and_return(mock_day = rand_int)
    
    month.day(day_value).should == mock_day
    
  end
  
  it "should another one for weeks" do
    pending if defined? Week
  end

end

describe 'all unit classes' do

  it "should have CleanName included" do
    UNIT_CLASSES.each do |klass|
      class << klass
        ancestors
      end.include?(Utility::CleanName).should == true
    end
  end

end