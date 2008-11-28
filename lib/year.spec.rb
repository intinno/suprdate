require 'year'

module YearHelpers
  
  def rand_int(size = 80_000) # smoke tested in IRB
    (rand * size).round - size / 2
  end
  
  def y(x)
    Year.new(x)
  end
  
end

describe 'year is an integer' do

  include YearHelpers

  it "should initialize with an integer" do
    3.times { y(ex = rand_int).to_i.should == ex }
  end
  
  it "should be comparable with years" do
    (y(ex = rand_int) == y(ex)).should == true
    (y(ex = rand_int) == y(ex + 1)).should == false
  end
  
  it "should know the successive year" do
    y(0).succ.should == y(1)
    (y(0) .. y(3)).to_a.should == [y(0), y(1), y(2), y(3)]
  end
  
  it "should respond to addition with an integer" do
    (y(a = rand_int) + b = rand_int).should == y(a + b)
  end
  
  it "should respond to subtraction with an integer" do
    (y(a = rand_int) - b = rand_int).should == y(a - b)
  end
  
end

describe 'year as ancestor to sub divisions' do

  include YearHelpers

  it "should return an array of months" do
    year = y(0)
    expected = rand_int
    month_class = mock 'month class'
    month_class.should_receive(:new).with(year, an_instance_of(Integer)).
      exactly(12).times.and_return expected
    year.month_class = month_class
    months = year.months
    months.nitems.should == 12
    months[0].should == expected
  end

end