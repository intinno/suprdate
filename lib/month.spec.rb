describe 'month creation' do

  def m(*args)
    Month.new(*args)
  end

  it "should work from a symbol" do
    m(:jan).to_i.should == 1
    m(:feb).to_i.should == 2
  end

end