module EachBreaker

  def setup(limit = 20)
    @iterations = 0
    @limit = limit
  end
  
  def succ
    p :succ
    @iterations += 1
  end
  
  def <=>(compare)
    p :<=>
    return 1 if @iterations > @limit
    super(compare)
  end
  
end

describe EachBreaker, 'allow me to test infinity' do

  it "should limit iterations" do
    range = (0..100)
    range.extend(EachBreaker)
    range.setup(3)
    range.to_a.should == [0, 1, 2]
  end

end

describe 'range enumeration' do
  
  def y(*args) Year(*args) end
  def m(*args) Month(*args) end
  def d(*args) Day(*args) end
    
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

  it "should work with years and weeks" do
    pending
  end

  it "should work with years and days" do
    (y(2008)..d(2008, 1, 3)).to_a.should == [y(2008)]
    (y(2008)..d(2009, 1, 3)).to_a.should == [y(2008), y(2009)]
    (d(2008, 12, 30)..y(2009)).to_a.should == [d(2008, 12, 30), d(2008, 12, 31), d(2009, 1, 1)]
  end

  it "should work with months and weeks" do
    pending
  end

  it "should work with weeks and days" do
    pending
  end

  it "should work with years and infinity" do
    pending
    range = (y(2008)..Inf)
  end

  it "should work with months and infinity" do
    pending
  end

  it "should work with weeks and infinity" do
    pending
  end

  it "should work with days and infinity" do
    pending
  end

end

