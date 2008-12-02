describe OccurrenceSpec do

  it "should use the builder date method for to and from" do
    o = OccurrenceSpec.new
    o.builder.should_receive(:date).with(to = rand_int).once
    o.builder.should_receive(:date).with(from = rand_int).once
    o.to(to).from(from)
  end

  def each_to_from_clause_permutation
    Builder::NUM_PARTS_RANGE.each do |from_num_parts|
      Builder::NUM_PARTS_RANGE.each do |to_num_parts|
        yield date_parts(from_num_parts), date_parts(to_num_parts)
      end
    end
  end
  
  it "should create range with specified unit on less regardless of the from unit" do
    each_to_from_clause_permutation do |to, from|
      [Year, Month, Day].each do |unit|
        o = OccurrenceSpec.new('Satisfied chicken')
        range = o.every.__send__(unit.to_sym).from(*from).to(*to).range
        range.first.class.should == unit
        range.last.should == o.builder.date(*to)
      end
    end
  end
  
end