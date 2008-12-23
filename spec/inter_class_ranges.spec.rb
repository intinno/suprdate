# http://refactormycode.com/codes/681-rspec-example-does-not-contain-a-should

describe 'range enumeration' do
  
  def enumerate_infinitely_with(expected)
    simple_matcher('enumerate infinitely with') do |given, matcher|
      matcher.failure_message = "expected #{given} to enumerate infinitely with #{expected}"
      matcher.negative_failure_message = "expected #{given} not to enumerate infinitely with #{expected}"
      test_times = 50
      (given..expected).each do |x|
        test_times -= 1
        break if test_times <= 0
      end
      test_times == 0
    end
  end

  it "each class should readers that return equivalents of other class" do
    y(2008).month.should == m(2008, 1)
    y(2008).day.should === d(2008, 1, 1)
    m(2008, 1).day.should === d(2008, 1, 1)
    (itself = y(2008)).year.should == itself
    (itself = m(2008, 1)).month.should == itself
    (itself = d(2008, 1, 1)).day.should == itself
  end

  it "should work with years and months" do
    (y(2008)..m(2008, 03)).to_a.should == [y(2008)]
    (y(2008)..m(2009, 03)).to_a.should == [y(2008), y(2009)]
    (m(2008, 11)..y(2009)).to_a.should == [m(2008, 11), m(2008, 12), m(2009, 1)]
  end

  it "should work with years and days" do
    (y(2008)..d(2008, 1, 3)).to_a.should == [y(2008)]
    (y(2008)..d(2009, 1, 3)).to_a.should == [y(2008), y(2009)]
    (d(2008, 12, 30)..y(2009)).to_a.should == [d(2008, 12, 30), d(2008, 12, 31), d(2009, 1, 1)]
  end

  it "should work with infinity" do
    y(2008).should enumerate_infinitely_with(Inf)
    m(2008, 10).should enumerate_infinitely_with(Inf)
    d(2008, 10, 1).should enumerate_infinitely_with(Inf)
    w(2008, 1).should enumerate_infinitely_with(Inf) if defined? Week
  end

end

