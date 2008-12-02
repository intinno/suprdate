describe OccurrenceSpec do

  it "should use the builder date method for to and from" do
    o = OccurrenceSpec.new
    o.builder.should_receive(:date).with(to = rand_int).once
    o.builder.should_receive(:date).with(from = rand_int).once
    o.to(to).from(from)
  end

  def assert(to, from, unit_klass, unit_as_sym)
    o = OccurrenceSpec.new('Satisfied chicken')
    range = o.every.__send__(unit_as_sym).from(*from).to(*to).range
    range.first.class.should == unit_klass
    range.last.should == o.builder.date(*to)
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