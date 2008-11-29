require 'month'

module MonthHelpers
  
  # ollie, lleeaavve it!
  def m(a, b = nil)
    return Month.new(Year.new(2001), a) if b.nil?
    Month.new(Year.new(a), b)
  end
  
end

describe 'month creation' do

  include MonthHelpers

  it "should work from an integer" do
    m(1).to_sym.should == :jan
    lambda { m(13) }.should raise_error
    lambda { m(0) }.should raise_error
  end

  it "should work from a symbol" do
    m(:jan).to_i.should == 1
    m(:feb).to_i.should == 2
  end
  
end

describe 'month comprised of days' do

  include MonthHelpers
  
  it "should know number of days" do
    m(11).num_days.should == 30
    m(12).num_days.should == 31
    m(2001, 2).num_days.should == 28
    m(2000, 2).num_days.should == 29
  end
  
  def init(month)
    @month = month
    @month.day_class = @day_class = mock('day class')
    @expected = rand_int
  end
  
  # refactor candidate: ideally this should be a special rspec expectation
  def days(month, num_days)
    init month
    @day_class.should_receive(:new).
      with(@month, an_instance_of(Integer)).
      exactly(num_days).times.and_return @expected
    day = @month.days
    day.nitems.should == num_days
    day[0].should == @expected
  end

  it "should return an array of days" do
    days m(11), 30
    days m(12), 31
  end
  
  it "should provide multiple individual days on demand" do
    init m(1)
    @day_class.should_receive(:new).with(@month, 1).once.and_return 1
    @day_class.should_receive(:new).with(@month, 3).once.and_return 2
    @day_class.should_receive(:new).with(@month, 5).once.and_return 3
    @month.day(1, 3, 5).should == [1, 2, 3]
  end
  
end

describe 'month math and logic' do

  include MonthHelpers

  it "should be comparable" do
    (m(11) == m(11)).should == true
    (m(10) == m(11)).should == false
    (m(2001, 11) == m(2000, 11)).should == false
    (m(11) > m(12)).should == false
    (m(12) > m(11)).should == true
    (m(2001, 11) > m(2000, 11)).should == true
    (m(2000, 11) > m(2001, 11)).should == false
  end
  
  it "should be able to add integers to months" do
    (m(11) + 1).should == m(12)
    (m(1999, 11) + 2).should == m(2000, 1)
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