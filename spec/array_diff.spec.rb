require File.dirname(__FILE__) + '/spec_helper'

describe 'array diff' do

  it 'should remove equal year elems' do
    ([y(2010), y(2011)] - [y(2010)]).should == [y(2011)]
  end

  it 'should remove equal month elems' do
    ([m(2010,1), m(2010, 2)] - [m(2010,1)]).should == [m(2010, 2)]
  end

  it 'should remove equal day elems' do
    ([d(2010, 1, 1), d(2010, 1, 2)] - [d(2010, 1, 1)]).should == [d(2010, 1, 2)]
  end

end