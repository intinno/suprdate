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
  
  it "should build today" do
    Builder.new.today.should be_instance_of(Day)
    Builder.new.today.to_s.should == Time.now.strftime(Day::STRFTIME_STR)
  end
  
end

describe Builder, 'date method' do

  it "should abstract the other methods of Builder" do
    Builder::DATE_NUM_PARTS_RANGE.each do |num_parts|
      b = Builder.new
      b.should_receive(Builder::UNIT_NUM_PARTS[num_parts]).once.and_return(expected = rand_int)
      b.date(*date_parts(num_parts)).should == expected
    end
  end
  
  it "should raise if wrong number of args" do
    lambda { Builder.new.date(1,2,3,4) }.should raise_error(DateConstructionError)
    lambda { Builder.new.date() }.should raise_error(DateConstructionError)
  end

end

describe Builder, 'exported builder methods' do
  
  it "should be defined" do
    defined = ['Year', 'Month', 'Day', 'Event', 'Repeats', 'Date', 'Today'].each { |e| respond_to?(e).should == true }
    (Builder.builder_methods.map { |m| m.to_export } - defined).should == []
    Day(2008, 10, 10).should == DEFAULT_BUILDER.day(2008, 10, 10)
  end

end

describe Builder, 'event' do

  it "should create a paragraph" do
    DEFAULT_BUILDER.event.should be_kind_of(DSL::Sentence)
  end
  
end