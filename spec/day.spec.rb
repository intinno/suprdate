require File.dirname(__FILE__) + '/spec_helper'

describe Day, 'creation' do

  it "should work from an integer" do
    d(2000, 1, 1).to_s.should == '2000-01-01'
    d(2000, 1, 8).to_s.should == '2000-01-08'
    d(2000, 2, 3).to_s.should == '2000-02-03'
    d(1999, 3, 4).to_s.should == '1999-03-04'
  end

  it "should prevent the creation of impossible days" do
    lambda { d(2000, 1, 40) }.should raise_error(DateConstructionError)
    lambda { d(2000, 2, 30) }.should raise_error(DateConstructionError)
    lambda { d(2000, 4, 31) }.should raise_error(DateConstructionError)
  end

end

describe Day, 'readers' do

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
    # returns are representitive:
    day.date.strftime('%Y-%m-%d').should == day.to_s
    day.time.strftime('%Y-%m-%d').should == day.to_s
    day.datetime.strftime('%Y-%m-%d').should == day.to_s
  end

  it "should return appropriate symbol" do
    d(2008, 11,  2).weekday_occurrence_this_month.should == :first
    d(2008, 11,  9).weekday_occurrence_this_month.should == :second
    d(2008, 11, 30).weekday_occurrence_this_month.should == :fifth
    d(2008, 11, 19).weekday_occurrence_this_month.should == :third
  end

  it "should know when it is one" do
    d(2000, 2, 29).leap?.should == true
    d(2000, 2, 28).leap?.should == false
    lambda { d(2001, 2, 29) }.should raise_error(DateConstructionError)
  end

end

describe Day, 'math and logic' do

  it "should be comparable" do
    (d(2000, 1, 21) == d(2000, 1, 21)).should == true
    (d(2000, 1, 20) == d(2000, 1, 21)).should == false
    (d(2000, 6, 21) == d(2000, 5, 21)).should == false
    (d(2000, 5, 21) == d(2001, 5, 21)).should == false
    (d(2000, 1, 21) >  d(2000, 1, 22)).should == false
    (d(2000, 1, 22) >  d(2000, 1, 21)).should == true
    (d(2000, 6, 21) >  d(2000, 5, 21)).should == true
    (d(2000, 5, 21) >  d(2000, 6, 21)).should == false
    (d(2000, 5, 21) >  d(2001, 5, 21)).should == false
    (d(2001, 5, 21) >  d(2000, 5, 21)).should == true
  end

  it "should be able to add with integers" do
    (d(2000, 1,  11) + 1).should == d(2000, 1, 12)
    (d(1999, 12, 31) + 1).should == d(2000, 1, 1)
    # accounts for leap
    (d(2000, 2,  28) + 2).should == d(2000, 3, 1)
    (d(2001, 2,  28) + 2).should == d(2001, 3, 2)
  end

  it "should be able to subtract with integers" do
    (d(2000, 1, 12) - 1).should == d(2000, 1, 11)
    (d(2000, 1,  1) - 1).should == d(1999, 12, 31)
    # accounts for leap
    (d(2000, 3,  1) - 2).should == d(2000, 2, 28)
    (d(2001, 3,  2) - 2).should == d(2001, 2, 28)
  end

  it "should hold state after arithmetic" do
    a = d(2000, 1, 28)
    # Because Day has no writable state of it's own (but Year does) I am assigning a random value
    # to month_factory (an attribute on the year).
    a.year.month_factory = expected = rand_int
    b = a + 5 # the month and the day change
    # but the month should still hold the original random value
    b.year.month_factory.should == expected
    b.object_id.should_not == a.object_id
  end

  it "should be enumerable in a range" do
    (d(2000, 1, 1)..d(2000, 1, 4)).to_a.should == [
      d(2000, 1, 1), d(2000, 1, 2), d(2000, 1, 3), d(2000, 1, 4)
    ]
  end

  it "should be able to get days since and until other days" do
    d(2000, 1, 3).since(d(2000, 1, 1)).should == 2
    d(2000, 2, 1).since(d(2000, 1, 1)).should == 31
    d(2000, 1, 1).until(d(2000, 1, 3)).should == 2
    d(2000, 1, 1).until(d(2000, 2, 1)).should == 31
  end

  it "should be able to get days since and until other months and years" do
    d(2000, 1, 3).since(m(2000, 1)).should == 2
    d(2000, 1, 3).since(y(2000)).should == 2
    d(2000, 3, 3).since(m(2000, 3)).should == 2
    d(2000, 1, 3).since(y(2000)).should == 2
  end

end
