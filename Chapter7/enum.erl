-module(enum).
-export([day/0, month/0]).


%% Exercise 7-8: Enumerated Types

% Days

-define(MONDAY,    1).
-define(TUESDAY,   2).
-define(WEDNESDAY, 3).
-define(THURSDAY,  4).
-define(FRIDAY,    5).
-define(SATURDAY,  6).
-define(SUNDAY,    7).

% Months
-define(JANUARY,   1).
-define(FEBRUARY,  2).
-define(MARCH,     3).
-define(APRIAL,    4).
-define(MAY,       5).
-define(JUNE,      6).
-define(JULY,      7).
-define(AUGUST,    8).
-define(SEPTEMBER, 9).
-define(OCTOBER,   10).
-define(NOVEMBER,  11).
-define(DECEMBER,  12).


day() -> ?THURSDAY.
month() -> ?AUGUST.
