#const horizon=100.
#const bound=0.
% cycle limit
#const lim=4.

time(1..horizon).
goal(bound).
inf_cap(20000000000).
unit(100000).

cycle(J,N) :- controllable(J), available_conf(J,C), N=#sum{T,S : phase_limit(S,C,T)}.
:- cycle(J,N1), cycle(J,N2), N1>N2.
% prev_status(S1,S2): 
%    S1 occurs before S2 in a cycle
prev_status(S,S1) :- next(S1,S), not end(S1).
prev_status(S,S2) :- prev_status(S,S1), next(S2,S1), not end(S2).

% sub(J,M): 
%    junction J starts at time M (note: the time is relative to the first cycle of J)
sub(J,TS+M) :- active_conf(0,J,A), status(J,S), active(0,S), time(0,J,TS), M=#sum{GT,S1 : prev_status(S,S1), phase_limit(S1,A,GT) }.

% time_step(J,C,T):
%    for each controllable junction J, the C-th cycle ends at time T 
% case 1: first cycle
time_step(J,1,D-M) :- controllable(J), cycle(J,D), sub(J,M), D-M<=horizon.
% case 2: following cycles
time_step(J,C,T+D) :- time_step(J,C-1,T), cycle(J,D), T+D<=horizon, C>1.


% configuration(J,C,T,A): 
%    for each controllable junction J, the C-th cycle start at time T with the configuration A
configuration(J,0,0,A) :- active_conf(0,J,A).
{configuration(J,C,T,A) : available_conf(J,A) } = 1 :- time_step(J,C,T).

% change(J,C,T,A):
%    at time T (which is the C-th decision point for the junction J), the configuration A is changed
change(J,C,T,A) :- configuration(J,C,T,A), 0<C, not configuration(J,C-1,_,A).

% no change of configuration before cycle limit (constant lim)
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

% follows(J,L):
%    the junction J follows the link L
follows(J2, link(J1,L,J2)):- link(J1,L,J2). 
% precedes(J,L):
%    the junction J precedes the link L
precedes(J1, link(J1,L,J2)):- link(J1,L,J2). 

link(link(J1,L,J2)) :- link(J1,L,J2).

% in_ord(L,L1,N):
%    L1 is the Nth incoming link (sorted according to the lex-order) for the link L  
in_ord(L,L1,N) :- turnrate(_,L1,L,_), N = #count{L2 : turnrate(_,L2,L,_), L2 <= L1}.

% out_ord(L,L1,L):
%    L1 is the Nth outgoing link (sorted according to the lex-order) for the link L 
out_ord(L,L1,N) :- turnrate(_,L,L1,_), N = #count{L2 : turnrate(_,L,L2,_), L2 <= L1}.


% full_link(T,L,0) -> the link L at time T is full
% full_link(T,L,1) -> the link L at time T is not full
% Alternative 1
%{full_link(T,L,0)} :- link(L), time(T).
%&sum{ occupancy(T,L);0 } > C:- full_link(T,L,0), capacity(L,C).
%&sum{ occupancy(T,L);0 } <= C:- full_link(T,L,1), capacity(L,C).
% Alternative 2
full_link(T,L,0) :- &sum{ occupancy(T,L) } >= C, time(T), capacity(L,C).
full_link(T,L,1) :- time(T), link(L), capacity(L,_), not full_link(T,L,0).

full_link(0,L,0) :- link(L), initial_occ(L,O), capacity(L,C), O>=C.
full_link(0,L,1) :- link(L), initial_occ(L,O), capacity(L,C), O<C.
full_link(0..horizon,L,1) :- link(L), not capacity(L,_).
full_link(0..horizon,outside,1).


% empty_link(T,L,0) -> the link L at time T is empty
% empty_link(T,L,1) -> the link L at time T is not empty
% Alternative 1
%{empty_link(T,L,0)} :- time(T), link(L).
%&sum{ occupancy(T,L);0 } < 99999 :- empty_link(T,L,0).
%&sum{ occupancy(T,L); 0} >= 100000 :- empty_link(T,L,1).
% Alternative 2
empty_link(T,L,0) :- &sum{ occupancy(T,L)} <= 0, time(T), link(L).
empty_link(T,L,1) :- time(T), link(L), not empty_link(T,L,0).

empty_link(0,L,1) :- link(L), initial_occ(L,O),  O>0.
empty_link(0,L,0) :- link(L), initial_occ(L,O),  O<=0.
empty_link(0..horizon,outside,1).

% for the link L, there are N incoming link
last_delta_in(N,L) :- link(L), N=#count{L1 : in_ord(L,L1,M)}.
% for the link L, there are N outgoing link
last_delta_out(N,L) :- link(L), N=#count{L1 : out_ord(L,L1,M)}.

% delta(T,N,L,D):
%   for every link L, there is a set of ordered atoms delta/4 that incrementally compute the delta at time T
%   the Nth delta contains the number D.
delta(T,0,L,0) :- time(T), link(L).
%   from 1 to last_delta_in -> incremets
delta(T,N,L,D+R*E*F) :- time(T), precedes(J,L), status(J,S), active(T-1,S), delta(T,N-1,L,D), in_ord(L,L1,N), turnrate_gez(S,L1,L,R), empty_link(T-1,L1,E), full_link(T-1,L,F).
%   from last_delta_in to last_delta_in + last_delta_out -> increments - decrements
delta(T,M+N,L,D-R*E*F) :- time(T), follows(J,L), status(J,S), active(T-1,S), delta(T,M+N-1,L,D), last_delta_in(M,L),out_ord(L,L1,N), turnrate_gez(S,L,L1,R), empty_link(T-1,L,E), full_link(T-1,L1,F).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Alternative order for delta (fist subtract then add)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%delta(T,N,L,D-R*E*F) :- time(T), follows(J,L), status(J,S), active(T-1,S), delta(T,N-1,L,D),out_ord(L,L1,N), turnrate_gez(S,L,L1,R), empty_link(T-1,L,E), full_link(T-1,L1,F).
%delta(T,M+N,L,D+R*E*F) :- time(T), precedes(J,L), status(J,S), active(T-1,S), delta(T,M+N-1,L,D), last_delta_out(M,L), in_ord(L,L1,N), turnrate_gez(S,L1,L,R), empty_link(T-1,L1,E), full_link(T-1,L,F).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sum_in(L,0..M) :- status(J,S), precedes(J,L), M=#sum{T,L1 : turnrate(S,L1,L,T)}.
sum_out(L,0..M) :- status(J,S), follows(J,L), M=#sum{T,L1 : turnrate(S,L,L1,T)}.

max_in(L,I) :- link(L), sum_in(L,I), not sum_in(L,I+1).
max_out(L,O) :- link(L), sum_out(L,O), not sum_out(L,O+1).
domain(L,-O,C+I) :- capacity(L,C), max_in(L,I), max_out(L,O).

&dom{Mi..Ma} = occupancy(T,L) :- domain(L,Mi,Ma), time(T).
&dom{-2*Z..C} = occupancy(T,L) :- not domain(L,_,_), inf_cap(C), unit(Z), link(L), time(T).


&sum{ D} = occupancy(0,L) :- initial_occ(L,D).
&sum{occupancy(T-1,L) ; D} = occupancy(T,L) :- delta(T,I+O,L,D), last_delta_out(O,L), last_delta_in(I,L).



&sum{ D} = counter(0,L) :- counter(0,L,D).
&sum{counter(T-1,L) ; D} = counter(T,L) :- delta(T,O,L,D), last_delta_in(O,L).

:- &sum{counter(horizon,L) } < B, counter(0,L,_), goal(B), B>0.
:- &sum{counter(horizon,L) : pddl_solution(L,_)} <= S, S=#sum{B,L : pddl_solution(L,B)}, pddl_solution(_,_).

&maximize{counter(horizon,L) : counter(0,L,_)}.

#show.
#show  sol(T-1,S,A1,A) : change(J,C,T,A), configuration(J,C-1,_,A1), active(T-1,S), status(J,S).
&show {counter(horizon,L) : counter(0,L,_)}.

