require 'rubygems'
require 'spec'
require File.expand_path(File.join(File.dirname(__FILE__), "..")) + '/lib/suprdate'
include Suprdate

def rand_int(size = 80_000) (rand * size).round - size / 2 end
def y_rand_int() (rand * 8000).round + 1600 end

def rand_between(range)
  (rand * (range.last - range.first)).round + range.first
end

def date_parts(num_parts)
  [rand_between(1600..2000), rand_between(1..12), rand_between(1..28)][0..num_parts - 1]
end

alias :d :Day
alias :m :Month
alias :y :Year
alias :r :Repeats

Dir["#{BASE_DIR}/spec/*.spec.rb"].each { |f| require f }
Spec::Runner::ExampleGroupRunner.new(nil)