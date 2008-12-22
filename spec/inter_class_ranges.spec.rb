describe 'range enumeration' do
  
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

  def with_infinity(date_unit)
    limit = 20
    (date_unit..Inf).each do |x|
      limit -= 1
      break if limit <= 0
    end
    limit.should == 0
  end

  it "should work with infinity" do
    # TODO: smell; no should here
    # http://refactormycode.com/codes/681-rspec-example-does-not-contain-a-should
    with_infinity y(2008)
    with_infinity m(2008, 10)
    with_infinity d(2008, 10, 1)
    pending 'Add weeks here' if defined? Week
  end

end

