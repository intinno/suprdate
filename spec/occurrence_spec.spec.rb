describe OccurrenceSpec do

  # TODO: this and the next two examples can be refactored to reduce duplication
  it "should create years with builder when one integer are provided in to and from methods" do
    o = OccurrenceSpec.new('Rancid beef')
    o.builder.should_receive(:year).with(2000).once
    o.builder.should_receive(:year).with(2003).once
    o.every.year.from(2000).to(2003)
  end
  
  it "should create months with builder when two integers are provided in to and from methods" do
    o = OccurrenceSpec.new('Limp turkey')
    o.builder.should_receive(:month).with(anything(), 10).once
    o.builder.should_receive(:month).with(anything(), 11).once
    o.every.year.from(2000, 10).to(2003, 11)
  end
  
  it "should create days with builder when three integers are provided in to and from methods" do
    o = OccurrenceSpec.new('Recumbent pork')
    o.builder.should_receive(:day).with(anything(), 1).once
    o.builder.should_receive(:day).with(anything(), 2).once
    o.every.year.from(2000, 10, 1).to(2003, 11, 2)
  end
  
  def occurrence_spec_range(params)
    o = OccurrenceSpec.new('Satisfied chicken')
    # these weird looking values have been choosen because they can both be mocked and put into a range
    from = 'f'; to = 'g'
    from.should_receive(params[:casts_to]).at_least(:once).and_return(from)
    to.should_receive(params[:casts_to]).at_least(:once).and_return(to)
    o.builder.stub!(:month) if [:day].include? params[:casts_to]
    o.builder.stub!(:year) if [:month, :day].include? params[:casts_to]
    o.builder.stub!(params[:casts_to]).at_least(:once).and_return(from, to)
    o.every.send(params[:casts_to]).from(*Array.new(params[:from])).to(*Array.new(params[:to])).range.should == (from..to)
  end
  
  it "should create range a using from and to clauses cast into specified unit" do
    occurrence_spec_range(:from => 1, :to => 1, :casts_to => :year)
    occurrence_spec_range(:from => 2, :to => 2, :casts_to => :month)
  end
  
end