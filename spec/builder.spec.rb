describe Builder, 'normal unit methods' do

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

describe Builder, 'date method' do

  it "should abstract the other methods of Builder" do
    Builder::NUM_PARTS_RANGE.each do |num_parts|
      b = Builder.new
      b.should_receive(Builder::METHODS_FOR_NUM_PARTS[num_parts]).once.and_return(expected = rand_int)
      b.date(*date_parts(num_parts)).should == expected
    end
  end
  
  it "should raise if wrong number of args" do
    lambda { Builder.new.date(1,2,3,4) }.should raise_error(ArgumentError)
    lambda { Builder.new.date() }.should raise_error(ArgumentError)
  end

end

describe Builder, 'exported builder methods' do
  
  it "should be defined" do
    # TODO: change this to use the builder_methods method
    respond_to?(:Year).should == true
    respond_to?(:Month).should == true
    respond_to?(:Day).should == true
    Day(2008, 10, 10).should == DEFAULT_BUILDER.day(2008, 10, 10)
  end

end

