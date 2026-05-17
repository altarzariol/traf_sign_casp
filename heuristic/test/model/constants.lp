#const horizon=100.
#const bound=0.
% cycle limit
#const lim=4.

time(1..horizon).
goal(bound).
inf_cap(20000000000).
unit(100000).

%---------------------------------------------
%#const threshold_lim = bound/2.
%threshold(TS) :- TS = threshold_lim.
%
%#show bound.
%#show threshold/1.
