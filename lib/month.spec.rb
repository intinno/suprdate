require 'month'

describe 'month creation' do

  def m(value)
    Month.new(0, value)
  end

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