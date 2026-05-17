cycle(J,N) :- controllable(J), available_conf(J,C), N=#sum{T,S : phase_limit(S,C,T)}.
:- cycle(J,N1), cycle(J,N2), N1>N2.

prev_status(S,S1) :- next(S1,S), not end(S1).
prev_status(S,S2) :- prev_status(S,S1), next(S2,S1), not end(S2).

sub(J,TS+M) :- active_conf(0,J,A), status(J,S), active(0,S), time(0,J,TS), M=#sum{GT,S1 : prev_status(S,S1), phase_limit(S1,A,GT) }.

% case 1: first cycle
time_step(J,1,D-M) :- controllable(J), cycle(J,D), sub(J,M), D-M<=horizon.
% case 2: following cycles
time_step(J,C,T+D) :- time_step(J,C-1,T), cycle(J,D), T+D<=horizon, C>1.

configuration(J,0,0,A) :- active_conf(0,J,A).
{configuration(J,C,T,A) : available_conf(J,A) } = 1 :- time_step(J,C,T).

change(J,C,T,A) :- configuration(J,C,T,A), 0<C, not configuration(J,C-1,_,A).

:- configuration(J,0,0,A), countcycle(0,J,I), C=1..lim-I-1, not configuration(J,C,T1,A), time_step(J,C,T1).
:- change(J,C,T,A), I=1..lim-1, not configuration(J,C+I,T1,A), time_step(J,C+I,T1).

% active_conf(T,J,A):
%    at time T, the configuration A is active in J
active_conf(1..horizon,J,A) :- configuration(J,0,0,A), not time_step(J,1,_), horizon>0.
active_conf(1..TS,J,A) :- configuration(J,0,0,A), time_step(J,1,TS).
active_conf(T..TS-1,J,A) :- configuration(J,C,T,A), time_step(J,C+1,TS), C>0.
active_conf(T..horizon,J,A) :- configuration(J,C,T,A), not time_step(J,C+1,_), C>0, horizon>=T.


% range(S,A,B,E):
%    when A is selected, the stage/interlimit phase S begin at time B and ends at time E 
%    (time relative to cycle)
range(S,A,M,M+L-1) :- available_conf(J,A), phase_limit(S,A,L), M=#sum{L1,S1 : prev_status(S,S1), phase_limit(S1,A,L1) }.

% active(T,S):
%    at time T the status S is active
% case 1: (first cycle)   ___|__.__|___
%                            B  M  E
active(1..E-M,S) :- configuration(J,0,0,A), sub(J,M), range(S,A,B,E), M<E, B<M.
% case 2: (first cycle)   ___.__|__|___
%                            M  B  E
active(B-M..E-M,S) :- configuration(J,0,0,A), sub(J,M), range(S,A,B,E), B>M.
% case 3: (first cycle)   ___|_____|___
%                           B/M    E       begin=B-M+1 since time 0 is given in input
active(1..E-M,S) :- configuration(J,0,0,A), sub(J,M), range(S,A,M,E).
% case 4: following cycles
active(T+B..T+E,S) :- configuration(J,C,T,A), C>0, range(S,A,B,E).

% time(T,J,TS):
%    at time T the junction J is active from TS seconds
% case 1: first cycle, no sub
time(X,J,X-B) :- configuration(J,0,0,A), sub(J,0), range(S,A,B,E), X=B..E.
% case 2: first cycle     ___.__.__.___
%                            B  M  E
time(X,J,M-B+X) :- configuration(J,0,0,A), sub(J,M), range(S,A,B,E), M>B, M<E, X=1..E-M.
% case 3: first cycle     ___.__.__.___
%                            M  B  E
time(X,J,X+M-B) :- configuration(J,0,0,A), sub(J,M), range(S,A,B,E), M>0, M<B, X=B-M..E-M.
% case 4: (first cycle)   ___|_____|___
%                           B/M    E       begin=B-M+1 since time 0 is given in input
time(X,J,X) :- configuration(J,0,0,A), sub(J,M), range(S,A,M,E), M>0, X=1..E-M.
% case 5: following cycles
time(T+X,J,X-B) :- configuration(J,C,T,A), C>0, range(S,A,B,E), X=B..E.

turnrate_gez(S,L1,L2,R) :- turnrate(S,L1,L2,R).
% add atoms for connections with missing turnrate 
turnrate_gez(S,link(J1,L1,J2),link(J2,L2,J3),0) :- link(J1,L1,J2), link(J2,L2,J3), status(J2,S), turnrate(S1,link(J1,L1,J2),link(J2,L2,J3),_), S1 != S, not turnrate(S,link(J1,L1,J2),link(J2,L2,J3),_).
