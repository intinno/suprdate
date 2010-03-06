Suprdate
========

Objects that represent dates (Year, Month and Day etc.) These are used for the purposes of traversal, iteration and arithmetic.

Installation
------------

	cd ~ # or wherever you want it installed
	git clone git://github.com/olliesaunders/suprdate.git
	cd suprdate
	bin/run_specs # check to see that it's working (requires rspec)
	bin/irb # this script requires and includes the library, and starts an interactive ruby session

Inclusion
---------

	require PATH_TO_SUPRDATE + '/lib/suprdate'
	include Suprdate

Features
--------

	>> y = Year(2008) # => 2008
	>> y.leap? # => true
	>> y += 1 # => 2009
	>> y.leap? # => false
	>> y.months.class # => Array
	>> y.months[0..2] # => [2009-01, 2009-02, 2009-03]
	>> y.since(Year(2000)) # => 9
	>> y.month # => 2009-01
	>> y.day # => 2009-01-01
	>> y[2]   # => 2009-02
	>> y[2, 3, :jun] # => [2009-02, 2009-03, 2009-06]
	>> y.days[0..2] # => [2009-01-01, 2009-01-02, 2009-01-03]
	>> y.days.nitems # => 365

	>> m = Month(2008, 1) # => 2008-01
	>> m += 2 # => 2008-03
	>> m.to_s # => "2008-03"
	>> m.to_sym # => :mar
	>> m[1] # => 2008-03-01
	>> m[1, 3] # => [2008-03-01, 2008-03-03]
	>> m[1, 3, -1, -3] # => [2008-03-01, 2008-03-03, 2008-03-31, 2008-03-29]
	>> m > Year(2008) # => true
	>> m > Year(2009) # => false
	>> m > Month(2008, 2) # => true
	>> m > Month(2008, 3) # => false
	>> m += 24 # => 2010-03

	>> y.month # => 2009-01
	>> d = y.day # => 2009-01-01
	>> d = Day(2009, 1, 1) # 2009-01-01
	>> d.until(d.month + 1) # => 31 # num days until the next month
	>> d.since(d.month - 2) # => 61 # num days since two months ago
	>> d.of_week_as_s # => "Thursday"
	>> d.of_week_as_sym # => :thu
	>> d.of_week_as_i  # => 5
	>> d.date # => #<Date: 4909665/2,0,2299161>
	>> d.date.strftime("%Y-%m-%d") # => "2009-01-01"
	>> d.weekday_occurrence_this_month # => :first
	>> (d + 7).weekday_occurrence_this_month # => :second
	>> (d + 21).weekday_occurrence_this_month # => :fourth

	>> Today() # => 2008-11-30
	>> Date(2000) # => 2000
	>> Date(2000, 10) # => 2000-10
	>> Date(2000, 10, 1) # => 2000-10-01

You can also do things with ranges:

	>> (Day(2008, 1, 1)..Day(2008, 1, 3)).to_a # => [2008-01-01, 2008-01-02, 2008-01-03]
	>> (Month(2008, 1)..Day(2008, 3, 10)).to_a # => [2008-01, 2008-02, 2008-03]
	>> (Year(2005)..Day(2009, 1, 3)).to_a # => [2005, 2006, 2007, 2008, 2009]

Note that the value you provide on the right side of the range is implicitly converted to the
same type as one the left so that they can be enumerated. This means the type you use on the
left of the range will determine the type of the output.

`(Year(2005)..Infinity)` creates a range that has no end. If you call `#to_a` on it ruby will go into an
infinite loop. Call each on this to iterate until you wish to break.

Currently there are no week objects. It's on the TODO.

The lone-standing every method can be used to filter any list by a specified frequency:

	>> every(3, Year(2008).months)
	=> [2008-01, 2008-04, 2008-07, 2008-10]
	>> every(:third, Year(2008).months)
	=> [2008-01, 2008-04, 2008-07, 2008-10]

It will accept a block too if you are that way inclined. If a block is given `every` will
return the original list unaltered.

Meta-Programming
----------------

Currently there is a single meta-programming technique in use in Suprdate

The methods beginning with an uppercase such as `Year`, `Month` and `Day` and `Today` are created 
dynamically at require time and actually each represent calls to `DEFAULT_BUILDER`: 

	>> Year(2008) == DEFAULT_BUILDER.year(2008) # => true
	>> Year(2008) == Builder.new.year(2008) # => true

This is done to make the existence of a builder completely transparent to the developer.
At present I can see no reason to interact with the builder, define you own builders or
worry about this for any reason.
