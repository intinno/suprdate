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

end