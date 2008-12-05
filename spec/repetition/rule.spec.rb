describe Repetition::Rule do

  it "should provide a range in a unit specified" do
    rule = Repetition::Rule.new
    rule.from = y(2008)
    rule.unit = mock('unit class')
    # casts the range into the unit
    rule.from.should_receive(unit_sym = :whatever).once.and_return(rule.from)
    # the method used for the cast is taken from the name of the unit itself
    rule.unit.should_receive(:to_sym).once.and_return(unit_sym)
    range = rule.range
    range.should be_kind_of(Range)
    range.first.should === rule.from
    # object id is necessary here because Inf is designed to never compare to true
    range.last.object_id.should === rule.to.object_id
  end

  it "should raise if a unit is not specified" do
    
  end

end