describe OccurrenceSpec do

  # TODO: make this a feature of the builder
  it "should create years with builder when one integer are provided in to and from methods" do
    o = OccurrenceSpec.new('Rancid beef')
    o.builder.should_receive(:year).with(2000).once
    o.builder.should_receive(:year).with(2003).once
    o.every.year.from(2000).to(2003)
  end
  
  it "should create months with builder when two integers are provided in to and from methods" do
    o = OccurrenceSpec.new('Limp turkey')
    o.builder.should_receive(:month).with(2000, 10).once
    o.builder.should_receive(:month).with(2003, 11).once
    o.every.year.from(2000, 10).to(2003, 11)
  end
  
  it "should create days with builder when three integers are provided in to and from methods" do
    o = OccurrenceSpec.new('Recumbent pork')
    o.builder.should_receive(:day).with(2000, 10, 1).once
    o.builder.should_receive(:day).with(2003, 11, 2).once
    o.every.year.from(2000, 10, 1).to(2003, 11, 2)
  end
  
  #def occurrence_spec_range(params)
  #  o = OccurrenceSpec.new('Satisfied chicken')
  #  # these weird looking values have been choosen because they can both be mocked and put into a range
  #  from = 'f'; to = 'g'
  #  from.should_receive(params[:casts_to]).at_least(:once).and_return(from)
  #  to.should_receive(params[:casts_to]).at_least(:once).and_return(to)
  #  o.builder.stub!(:month) if [:day].include? params[:casts_to]
  #  o.builder.stub!(:year) if [:month, :day].include? params[:casts_to]
  #  o.builder.stub!(params[:casts_to]).at_least(:once).and_return(from, to)
  #  o.every.send(params[:casts_to]).from(*Array.new(params[:from])).to(*Array.new(params[:to])).range.should == (from..to)
  #  
  #end
  
  def assert(to, from, unit_klass, unit_as_sym)
    o = OccurrenceSpec.new('Satisfied chicken')
    range = o.every.__send__(unit_as_sym).from(*from).to(*to).range
    range.first.class.should == unit_klass
    range.last.should == o.build(to)
  end
  
  def rand_between(range)
    (rand * (range.last - range.first)).round + range.first
  end
  
  def rand_date_parts(num_parts)
    [rand_between(1600..2000), rand_between(1..12), rand_between(1..28)][0..num_parts - 1]
  end
  
  NUM_PARTS_RANGE = 1..3
  
  def each_to_from_clause_permutation
    NUM_PARTS_RANGE.each do |from_num_parts|
      NUM_PARTS_RANGE.each do |to_num_parts|
        yield rand_date_parts(from_num_parts), rand_date_parts(to_num_parts)
      end
    end
  end
  
  it "should create range with specified unit on less regardless of the from unit" do
    units = [[Year, :year], [Month, :month], [Day, :day]]
    each_to_from_clause_permutation do |to, from|
      units.each { |unit| assert(to, from, unit[0], unit[1]) }
    end
  end
  
end