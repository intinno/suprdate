require 'day'

module DayHelpers
  
  def d(a, b = nil, c = nil)
    return Day.new(Month.new(Year.new(a), b), c) if c
    return Day.new(Month.new(Year.new(2000), a), b) if b
    Day.new(Month.new(Year.new(2000), 1), a)
  end
  
end

describe 'day creation' do

  include DayHelpers
  
  it "should work from an integer" do
    d(1).to_s.should == '2000-01-01'
    d(8).to_s.should == '2000-01-08'
    d(2, 3).to_s.should == '2000-02-03'
    d(1999, 3, 4).to_s.should == '1999-03-04'
  end
  
  it "should prevent the creation of impossible days" do
    lambda { d(2000, 1, 40) }.should raise_error
    lambda { d(2000, 2, 30) }.should raise_error
    lambda { d(2000, 4, 31) }.should raise_error
  end

end

describe 'various day getters' do

  include DayHelpers

  it "should give you the day of the year" do
    d(2000, 1, 1).of_year.should == 1
    d(2000, 1, 5).of_year.should == 5
    d(2000, 2, 2).of_year.should == 33
  end
  
  it "should give you the day of the week" do
    d(2008, 11, 28).of_week_as_s.should == "Friday"
    d(2008, 11, 28).of_week_as_sym.should == :fri
    d(2008, 11, 28).of_week_as_i.should == 5
    d(2008, 11, 31).of_week_as_i.should == 1
  end
  
  it "should give you equivalent Date, DateTime and Time objects" do
    day = d(2000, 1, 1)
    day.date.should be_instance_of Date
    day.time.should be_instance_of Time
    day.datetime.should be_instance_of DateTime
    day.date.strftime('%Y-%m-%d').should == day.to_s
    day.time.strftime('%Y-%m-%d').should == day.to_s
    day.datetime.strftime('%Y-%m-%d').should == day.to_s
  end

end

describe 'leap days' do

  it "should know when it is one" do
    d(2000, 2, 29).leap?.should == true
    d(2000, 2, 28).leap?.should == true
    lambda { d(2001, 2, 29) }.should raise_error
  end

end

describe 'day math and logic' do

  include DayHelpers

  it "should be comparable" do
    (d(21) == d(21)).should == true
    (d(20) == d(21)).should == false
    (d(6, 21) == d(5, 21)).should == false
    (d(2000, 5, 21) == d(2001, 5, 21)).should == false
    (d(21) > d(22)).should == false
    (d(22) > d(21)).should == true
    (d(6, 21) > d(5, 21)).should == true
    (d(5, 21) > d(6, 21)).should == false
    (d(2000, 5, 21) > d(2001, 5, 21)).should == false
    (d(2001, 5, 21) > d(2000, 5, 21)).should == true
  end
  
  it "should be able to add integers to months" do
    (d(11) + 1).should == d(12)
    (d(1999, 11) + 2).should == d(2000, 1)
  end
  
  it "should be able to subtract integers from months" do
    (m(2001, 5) - 3).should == m(2001, 2)
    (m(2001, 1) - 1).should == m(2000, 12)
  end

  it "should hold state after arithmetic" do
    a = m(5)
    a.day_class = :foo
    b = a + 1
    b.day_class.should == :foo
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

end