#program base.
% Define time domain and basic constants (now provided by the Python script)
% horizon(H) comes from Python script instead of #const
% bound(B) comes from Python script instead of #const
% lim(L) comes from Python script instead of #const

inf_cap(20000000000).
unit(100000).

% Base program definitions - independent of time steps
cycle(J,N) :- controllable(J), available_conf(J,C), N=#sum{T,S : phase_limit(S,C,T)}.
:- cycle(J,N1), cycle(J,N2), N1>N2.

% prev_status(S1,S2): S1 occurs before S2 in a cycle
prev_status(S,S1) :- next(S1,S), not end(S1).
prev_status(S,S2) :- prev_status(S,S1), next(S2,S1), not end(S2).

% sub(J,M): junction J starts at time M (time is relative to first cycle of J)
sub(J,TS+M) :- active_conf(0,J,A), status(J,S), active(0,S), time(0,J,TS), M=#sum{GT,S1 : prev_status(S,S1), phase_limit(S1,A,GT) }.

% time_step(J,C,T): for each controllable junction J, C-th cycle ends at time T
% case 1: first cycle
time_step(J,1,D-M) :- controllable(J), cycle(J,D), sub(J,M), D-M <= H, horizon(H).
% case 2: following cycles
time_step(J,C,T+D) :- time_step(J,C-1,T), cycle(J,D), T+D <= H, horizon(H), C>1.

% configuration(J,C,T,A): for J, C-th cycle starts at time T with config A
configuration(J,0,0,A) :- active_conf(0,J,A).
{configuration(J,C,T,A) : available_conf(J,A) } = 1 :- time_step(J,C,T).

% change(J,C,T,A): at time T (C-th decision point for J), config A is changed
change(J,C,T,A) :- configuration(J,C,T,A), 0<C, not configuration(J,C-1,_,A).

% No change of configuration before cycle limit
:- configuration(J,0,0,A), countcycle(0,J,I), lim(L), C=1..L-I-1, not configuration(J,C,T1,A), time_step(J,C,T1).
:- change(J,C,T,A), lim(L), I=1..L-1, not configuration(J,C+I,T1,A), time_step(J,C+I,T1).

% range(S,A,B,E): when A is selected, phase S begins at B and ends at E
range(S,A,M,M+L-1) :- available_conf(J,A), phase_limit(S,A,L), M=#sum{L1,S1 : prev_status(S,S1), phase_limit(S1,A,L1) }.

% Initial time 0 setup
% active_conf at time 0
active_conf(0,J,A) :- configuration(J,0,0,A).

% Initial link state definitions
full_link(0,L,0) :- link(L), initial_occ(L,O), capacity(L,C), O>=C.
full_link(0,L,1) :- link(L), initial_occ(L,O), capacity(L,C), O<C.
full_link(0,L,1) :- link(L), not capacity(L,_).
full_link(0,outside,1).

empty_link(0,L,1) :- link(L), initial_occ(L,O), O>0.
empty_link(0,L,0) :- link(L), initial_occ(L,O), O<=0.
empty_link(0,outside,1).

% Delta and domain definitions - static part
turnrate_gez(S,L1,L2,R) :- turnrate(S,L1,L2,R).
turnrate_gez(S,link(J1,L1,J2),link(J2,L2,J3),0) :- link(J1,L1,J2), link(J2,L2,J3), status(J2,S), 
                                                 turnrate(S1,link(J1,L1,J2),link(J2,L2,J3),_), 
                                                 S1 != S, not turnrate(S,link(J1,L1,J2),link(J2,L2,J3),_).

follows(J2, link(J1,L,J2)):- link(J1,L,J2). 
precedes(J1, link(J1,L,J2)):- link(J1,L,J2). 
link(link(J1,L,J2)) :- link(J1,L,J2).

in_ord(L,L1,N) :- turnrate(_,L1,L,_), N = #count{L2 : turnrate(_,L2,L,_), L2 <= L1}.
out_ord(L,L1,N) :- turnrate(_,L,L1,_), N = #count{L2 : turnrate(_,L,L2,_), L2 <= L1}.

last_delta_in(N,L) :- link(L), N=#count{L1 : in_ord(L,L1,M)}.
last_delta_out(N,L) :- link(L), N=#count{L1 : out_ord(L,L1,M)}.

sum_in(L,0..M) :- status(J,S), precedes(J,L), M=#sum{T,L1 : turnrate(S,L1,L,T)}.
sum_out(L,0..M) :- status(J,S), follows(J,L), M=#sum{T,L1 : turnrate(S,L,L1,T)}.

max_in(L,I) :- link(L), sum_in(L,I), not sum_in(L,I+1).
max_out(L,O) :- link(L), sum_out(L,O), not sum_out(L,O+1).
domain(L,-O,C+I) :- capacity(L,C), max_in(L,I), max_out(L,O).

% Set initial occupancy and counter values
&dom{Mi..Ma} = occupancy(0,L) :- domain(L,Mi,Ma), initial_occ(L,_).
&dom{-2*Z..C} = occupancy(0,L) :- not domain(L,_,_), inf_cap(C), unit(Z), link(L), initial_occ(L,_).
&sum{ D} = occupancy(0,L) :- initial_occ(L,D).

&sum{ D} = counter(0,L) :- counter(0,L,D).
delta(0,0,L,0) :- link(L).

#program step(t).
% Time-dependent predicates for step t
time(t).

% Domain definitions for occupancy - incremental
&dom{Mi..Ma} = occupancy(t,L) :- domain(L,Mi,Ma), link(L).
&dom{-2*Z..C} = occupancy(t,L) :- not domain(L,_,_), inf_cap(C), unit(Z), link(L).

% active and time calculations for step t
% case 1: (first cycle) ___|__.__|___
%                           B  M  E
active(t,S) :- t > 0, configuration(J,0,0,A), sub(J,M), range(S,A,B,E), M<E, B<M, t <= E-M.
% case 2: (first cycle) ___.__|__|___
%                           M  B  E
active(t,S) :- t > 0, configuration(J,0,0,A), sub(J,M), range(S,A,B,E), B>M, t >= B-M, t <= E-M.
% case 3: (first cycle) ___|_____|___
%                          B/M    E    
active(t,S) :- t > 0, configuration(J,0,0,A), sub(J,M), range(S,A,M,E), t <= E-M.
% case 4: following cycles
active(t,S) :- configuration(J,C,T,A), C>0, range(S,A,B,E), t >= T+B, t <= T+E.

% time calculations for step t
time(t,J,t-B) :- t > 0, configuration(J,0,0,A), sub(J,0), range(S,A,B,E), t >= B, t <= E.
time(t,J,M-B+t) :- t > 0, configuration(J,0,0,A), sub(J,M), range(S,A,B,E), M>B, M<E, t <= E-M.
time(t,J,t+M-B) :- t > 0, configuration(J,0,0,A), sub(J,M), range(S,A,B,E), M>0, M<B, t >= B-M, t <= E-M.
time(t,J,t) :- t > 0, configuration(J,0,0,A), sub(J,M), range(S,A,M,E), M>0, t <= E-M.
time(t,J,t-T-B) :- t > 0, configuration(J,C,T,A), C>0, range(S,A,B,E), t >= T+B, t <= T+E.

% active_conf calculations for step t
active_conf(t,J,A) :- t > 0, configuration(J,0,0,A), horizon(H), t <= H, not time_step(J,1,_).
active_conf(t,J,A) :- t > 0, configuration(J,0,0,A), time_step(J,1,TS), t <= TS.
active_conf(t,J,A) :- t > 0, configuration(J,C,T,A), time_step(J,C+1,TS), C>0, t >= T, t < TS.
active_conf(t,J,A) :- t > 0, configuration(J,C,T,A), not time_step(J,C+1,_), C>0, horizon(H), t >= T, t <= H.

% Delta calculation for step t
delta(t,0,L,0) :- link(L).
delta(t,N,L,D+R*E*F) :- precedes(J,L), status(J,S), active(t-1,S), delta(t,N-1,L,D), 
                    in_ord(L,L1,N), turnrate_gez(S,L1,L,R), 
                    empty_link(t-1,L1,E), full_link(t-1,L,F).
delta(t,M+N,L,D-R*E*F) :- follows(J,L), status(J,S), active(t-1,S), delta(t,M+N-1,L,D), 
                      last_delta_in(M,L), out_ord(L,L1,N), turnrate_gez(S,L,L1,R), 
                      empty_link(t-1,L,E), full_link(t-1,L1,F).

% Full and empty link calculations for step t
full_link(t,L,0) :- &sum{ occupancy(t,L) } >= C, capacity(L,C).
full_link(t,L,1) :- link(L), capacity(L,_), not full_link(t,L,0).
full_link(t,L,1) :- link(L), not capacity(L,_).
full_link(t,outside,1).

empty_link(t,L,0) :- &sum{ occupancy(t,L)} <= 0, link(L).
empty_link(t,L,1) :- link(L), not empty_link(t,L,0).
empty_link(t,outside,1).

% Update occupancy and counter
&sum{occupancy(t-1,L) ; D} = occupancy(t,L) :- delta(t,I+O,L,D), last_delta_out(O,L), last_delta_in(I,L).
&sum{ counter(t-1,L) ; D } = counter(t,L)
  :- delta(t,O,L,D), last_delta_in(O,L), goal_count(L,_).

% Output conflict configuration changes as sol/4 atoms
sol(t-1,S,A1,A) :- change(J,C,t,A), configuration(J,C-1,_,A1), active(t-1,S), status(J,S).

#program check(t).
% Check program at the end of computation (horizon)
:- &sum{counter(t,L) } < B, counter(0,L,_), bound(B).
&maximize{counter(t,L) : counter(0,L,_)}.

#show.

&show {counter(t,L) : counter(0,L,_)}.