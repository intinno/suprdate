require 'day'

module DayHelpers
  
  def d(*args)
    day = make(*args)
    day.month.day_class = Day
    day.year.month_class = Month
    day
  end
  
  private 
  
    def make(a, b = nil, c = nil)
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

describe 'various day readers' do

  include DayHelpers

  it "should give you the day of the year" do
    d(2000, 1, 1).of_year.should == 1
    d(2000, 1, 5).of_year.should == 5
    d(2000, 2, 2).of_year.should == 33
  end
  
  it "should give you the day of the week" do
    d(2008, 11, 9).of_week_as_s.should == "Sunday"
    d(2008, 11, 29).of_week_as_sym.should == :sat
    d(2008, 11, 28).of_week_as_sym.should == :fri
    d(2008, 11, 28).of_week_as_i.should == 6
    d(2008, 12, 1).of_week_as_i.should == 2
  end
  
  it "should give you equivalent Date, DateTime and Time objects" do
    day = d(2000, 1, 1)
    day.date.should be_instance_of(Date)
    day.time.should be_instance_of(Time)
    day.datetime.should be_instance_of(DateTime)
    day.date.strftime('%Y-%m-%d').should == day.to_s
    day.time.strftime('%Y-%m-%d').should == day.to_s
    day.datetime.strftime('%Y-%m-%d').should == day.to_s
  end

  it "should return appropriate symbol" do
    d(2008, 11, 2).weekday_occurance_this_month.should == :first
    d(2008, 11, 9).weekday_occurance_this_month.should == :second
    d(2008, 11, 30).weekday_occurance_this_month.should == :fifth
    d(2008, 11, 19).weekday_occurance_this_month.should == :third
  end

  it "should know when it is one" do
    d(2000, 2, 29).leap?.should == true
    d(2000, 2, 28).leap?.should == false
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
  
  it "should be able to add with integers" do
    (d(11) + 1).should == d(12)
    (d(1999, 12, 31) + 1).should == d(2000, 1, 1)
    # accounts for leap
    (d(2000, 2, 28) + 2).should == d(2000, 3, 1)
    (d(2001, 2, 28) + 2).should == d(2001, 3, 2)
  end
  
  it "should be able to subtract with integers" do
    (d(12) - 1).should == d(11)
    (d(2000, 1, 1) - 1).should == d(1999, 12, 31)
    # accounts for leap
    (d(2000, 3, 1) - 2).should == d(2000, 2, 28)
    (d(2001, 3, 2) - 2).should == d(2001, 2, 28)
  end

  it "should hold state after arithmetic" do
    a = d(28)
    # day has no writable state of it's own but month does
    # so I'm setting a value on the month:
    # day_class is not used in any of these operations so it's ok to abuse it
    # with a nonsense value
    a.month.day_class = :foo 
    b = a + 5 # the month and the day changed
    # but the month should still hold the original state
    b.month.day_class.should == :foo
    b.object_id.should_not == a.object_id
  end
  
  it "should be rangeable" do
    (d(1)..d(4)).to_a.should == [d(1), d(2), d(3), d(4)]
  end
  
  it "should be able to get days since and until other days" do
    d(3).since(d(1)).should == 2
    d(2, 1).since(d(1, 1)).should == 31
    d(1).until(d(3)).should == 2
    d(1, 1).until(d(2, 1)).should == 31
  end

end
