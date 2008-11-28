def disarray(a) a.size == 1 ? a[0] : a end

WEEKDAYS_SYM_TO_I = {
  :mon => 1, :tue => 2, :wed => 3, :thu => 4, 
  :fri => 5, :sat => 6, :sun => 7
}
WEEKDAYS_I_TO_SYM = [nil, :mon, :tue, :wed, :thu, :fri, :sat, :sun]
WEEKDAY_RANGE = 1..7

MONTH_SYM_TO_I = {
  :jan => 1,    :feb => 2,    :mar => 3,
  :apr => 4,    :may => 5,    :jun => 6,
  :jul => 7,    :aug => 8,    :sep => 9,
  :oct => 10,   :nov => 11,   :dec => 12,
}
MONTH_I_TO_SYM = {
  1  => :jan,   2  => :feb,   3  => :mar,
  4  => :apr,   5  => :may,   6  => :jun,
  7  => :jul,   8  => :aug,   9  => :sep,
  10 => :oct,   11 => :nov,   12 => :dec,
}
MONTHS_IN_YEAR = 12
MONTH_RANGE = 1..MONTHS_IN_YEAR
NUM_DAYS_IN_MONTHS = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]