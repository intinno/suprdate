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
    lambda { every(:keith, [1,2,3]) }.should raise_error(IndexError)
  end
  
end

module BeAListOfIdenticialObjects
  
  def be_a_list_of_identicial_objects(expected)
    simple_matcher('be a list of the same objects') do |given, matcher|
      matcher.failure_message = "expected #{given.inspect} to be the same as #{expected.inspect}"
      matcher.negative_failure_message = 
        "expected #{given.inspect} not to be the same as #{expected.inspect}"
      sorted_object_ids(expected) == sorted_object_ids(given)
    end
  end
  
  private
  def sorted_object_ids(list) list.map { |x| x.object_id }.sort end
    
end

describe Suprdate::UNIT_CLASSES do

  include BeAListOfIdenticialObjects

  it "should contain all the units" do
    units = []
    Module.constants.each do |const|
      const = Kernel.const_get(const)
      next unless const.respond_to?(:ancestors)
      const.ancestors[1..-1].find { |x| units << const if x == Unit }
    end
    UNIT_CLASSES.should be_a_list_of_identicial_objects(units)
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

describe Utility::CleanConstantName do

  module FooNamespace
    class Monkey
      extend Utility::CleanConstantName
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

  it "should have CleanConstantName included" do
    UNIT_CLASSES.each do |klass|
      class << klass
        ancestors
      end.include?(Utility::CleanConstantName).should == true
    end
  end
  
  it "should have a leap? method" do
    UNIT_CLASSES.each { |c| c.public_method_defined?(:leap?).should == true }
  end
  
  it "should know its significance related to each other unit" do
    pending 'incomplete'
    (Year <=> Year).should == 0
    (Year <=> Month).should == 1
    (Year <=> Day).should == 1
    (Month <=> Year).should == -1
    (Month <=> Month).should == 0
    (Month <=> Day).should == 1
    (Day <=> Year).should == 1
    (Day <=> Month).should == 1
    (Day <=> Day).should == 0
    raise 'Missing weeks' if defined? Week
  end
  
  include BeAListOfIdenticialObjects
  
  it "should have polymorphic interfaces" do
    units = [y(2000), m(2000, 1), d(2000, 1, 1)]
    # to make sure these really are all the units.
    units.map { |i| i.class }.should be_a_list_of_identicial_objects(UNIT_CLASSES)
    units.each do |u|
      u.day.class.should == Day
      u.month.class.should == Month
      u.year.class.should == Year
      u.days[0].class.should == Day
    end
  end

end

describe UNIT_CLASSES, '#fetch_index' do

  it "should raise if attempting to get the index of something that doesn't exist" do
    lambda { UNIT_CLASSES.fetch_index('monkey') }.should raise_error(IndexError)
  end
  
  it "should return the index without raising for something that does exist" do
    lambda { UNIT_CLASSES.index(Year).should == 0 }.should_not raise_error
  end

end