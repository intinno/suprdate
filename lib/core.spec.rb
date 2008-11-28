def rand_int(size = 80_000) (rand * size).round - size / 2 end

describe 'disarray' do

  it "should return an array if 2 or more elements" do
    disarray(array = Array.new(2)).should == array
    disarray(array = Array.new(5)).should == array
    disarray(array = Array.new(10)).should == array
  end
  
  it "should return first element of a single element array" do
    disarray([:foo]).should == :foo
    disarray([80081355]).should == 80081355
  end

end