#program base.
% horizon(H), bound(B), lim(L) vengono dallo script Python

inf_cap(20000000000).
unit(100000).

% --- Atomo esterno per fissare le configurazioni decise negli shot precedenti ---
% Opzione A: Dichiarazione #external sicura con predicati di dominio
_junction_domain(J) :- controllable(J). % Usa un predicato esistente o definiscine uno ad hoc
_config_domain(C) :- available_conf(_,C).
_generic_time(T) :- horizon(H), T=0. % Generico, potrebbe essere raffinato
_generic_cycle_idx(C) :- horizon(H), C=0. % Generico, potrebbe essere raffinato (es. max cicli)

#external fixed_configuration(J, C_idx, T_val, Conf) :
    _junction_domain(J), _generic_cycle_idx(C_idx), _generic_time(T_val), _config_domain(Conf).

% Definizioni del programma base - indipendenti dai passi temporali
cycle(J,N) :- controllable(J), available_conf(J,C), N=#sum{T,S : phase_limit(S,C,T)}.
:- cycle(J,N1), cycle(J,N2), N1>N2.

prev_status(S,S1) :- next(S1,S), not end(S1).
prev_status(S,S2) :- prev_status(S,S1), next(S2,S1), not end(S2).

sub(J,TS+M) :- active_conf(0,J,A), status(J,S), active(0,S), time(0,J,TS), M=#sum{GT,S1 : prev_status(S,S1), phase_limit(S1,A,GT) }.

time_step(J,1,D-M) :-
    controllable(J),
    configuration(J,0,0,CfgForCycleD), 
    cycle(J,D), phase_limit(_,CfgForCycleD,_), 
    sub(J,M), D-M <= H, horizon(H).

time_step(J,C_idx,T_prev_shot_end + D) :-
    time_step(J,C_idx-1,T_prev_shot_end),
    configuration(J,C_idx-1,T_prev_shot_end,CfgForCycleD), 
    cycle(J,D), phase_limit(_,CfgForCycleD,_), 
    T_prev_shot_end + D <= H, horizon(H), C_idx>1.

configuration(J,0,0,A) :- active_conf(0,J,A).

configuration(J,C_idx,T_val,Conf) :- time_step(J,C_idx,T_val), fixed_configuration(J,C_idx,T_val,Conf).
:- time_step(J,C_idx,T_val), fixed_configuration(J,C_idx,T_val,Conf1), fixed_configuration(J,C_idx,T_val,Conf2), Conf1 != Conf2.

{configuration(J,C_idx,T_val,Conf) : available_conf(J,Conf) } = 1 :-
    time_step(J,C_idx,T_val),
    not fixed_configuration(J,C_idx,T_val,_).

change(J,C_idx,T_val,Conf) :- configuration(J,C_idx,T_val,Conf), 0<C_idx, not configuration(J,C_idx-1,_,Conf).

:- configuration(J,0,0,A), countcycle(0,J,I), lim(L), C_idx=1..L-I-1, not configuration(J,C_idx,T1,A), time_step(J,C_idx,T1).
:- change(J,C_idx,T_val,A), lim(L), I_offset=1..L-1, not configuration(J,C_idx+I_offset,T1,A), time_step(J,C_idx+I_offset,T1).

range(S,A,M,M+L-1) :- 
    available_conf(J,A), 
    phase_limit(S,A,L), 
    M=#sum{L1,S1 : prev_status(S,S1), phase_limit(S1,A,L1) }.

active_conf(0,J,A) :- configuration(J,0,0,A).
full_link(0,L,0) :- link(L), initial_occ(L,O), capacity(L,C), O>=C.
full_link(0,L,1) :- link(L), initial_occ(L,O), capacity(L,C), O<C.
full_link(0,L,1) :- link(L), not capacity(L,_).
full_link(0,outside,1).
empty_link(0,L,1) :- link(L), initial_occ(L,O), O>0.
empty_link(0,L,0) :- link(L), initial_occ(L,O), O<=0.
empty_link(0,outside,1).
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
&dom{Mi..Ma} = occupancy(0,L) :- domain(L,Mi,Ma), initial_occ(L,_).
&dom{-2*Z..C} = occupancy(0,L) :- not domain(L,_,_), inf_cap(C), unit(Z), link(L), initial_occ(L,_).
&sum{ D} = occupancy(0,L) :- initial_occ(L,D).
&sum{ D} = counter(0,L) :- counter(0,L,D).
delta(0,0,L,0) :- link(L). 

#show time_step/3.
#show configuration/4. 
#show active_conf/3.   

#program step(t).
time(t).
&dom{Mi..Ma} = occupancy(t,L) :- domain(L,Mi,Ma), link(L), t > 0.
&dom{-2*Z..C} = occupancy(t,L) :- not domain(L,_,_), inf_cap(C), unit(Z), link(L), t > 0.
active(t,S) :- t > 0, configuration(J,0,0,A), sub(J,M), range(S,A,B,E), M<E, B<M, t >= 1, t <= E-M.
active(t,S) :- t > 0, configuration(J,0,0,A), sub(J,M), range(S,A,B,E), B>M, t >= B-M, t <= E-M.
active(t,S) :- t > 0, configuration(J,0,0,A), sub(J,M), range(S,A,M,E), t >= 1, t <= E-M.
active(t,S) :- configuration(J,C,T_start_cycle,A), C>0, range(S,A,B,E), t >= T_start_cycle+B, t <= T_start_cycle+E.
time(t,J,t-B) :- t > 0, configuration(J,0,0,A), sub(J,0), range(S,A,B,E), t >= B, t <= E.
time(t,J,M-B+t) :- t > 0, configuration(J,0,0,A), sub(J,M), range(S,A,B,E), M>B, M<E, t >= 1, t <= E-M.
time(t,J,t+M-B) :- t > 0, configuration(J,0,0,A), sub(J,M), range(S,A,B,E), M>0, M<B, t >= B-M, t <= E-M.
time(t,J,t) :- t > 0, configuration(J,0,0,A), sub(J,M), range(S,A,M,E), M>0, t >= 1, t <= E-M.
time(t,J, t - (T_start_cycle+B) ) :- t > 0, configuration(J,C,T_start_cycle,A), C>0, range(S,A,B,E), t >= T_start_cycle+B, t <= T_start_cycle+E.
active_conf(t,J,A) :- t > 0, configuration(J,0,0,A), horizon(H), t >= 1, t <= H, not time_step(J,1,_).
active_conf(t,J,A) :- t > 0, configuration(J,0,0,A), time_step(J,1,TS), t >= 1, t <= TS.
active_conf(t,J,A) :- t > 0, configuration(J,C,T_start_cycle,A), time_step(J,C+1,TS_next_step), C>0, t >= T_start_cycle, t < TS_next_step.
active_conf(t,J,A) :- t > 0, configuration(J,C,T_start_cycle,A), not time_step(J,C+1,_), C>0, horizon(H), t >= T_start_cycle, t <= H.
delta(t,0,L,0) :- link(L), t > 0.
delta(t,N,L,D+R*E*F) :- precedes(J,L), status(J,S), active(t-1,S), delta(t,N-1,L,D),
                    in_ord(L,L1,N), turnrate_gez(S,L1,L,R),
                    empty_link(t-1,L1,E), full_link(t-1,L,F), t > 0.
delta(t,M+N,L,D-R*E*F) :- follows(J,L), status(J,S), active(t-1,S), delta(t,M+N-1,L,D),
                      last_delta_in(M,L), out_ord(L,L1,N), turnrate_gez(S,L,L1,R),
                      empty_link(t-1,L,E), full_link(t-1,L1,F), t > 0.
full_link(t,L,0) :- &sum{ occupancy(t,L) } >= C, capacity(L,C), t > 0.
full_link(t,L,1) :- link(L), capacity(L,_), not full_link(t,L,0), t > 0.
full_link(t,L,1) :- link(L), not capacity(L,_), t > 0.
full_link(t,outside,1) :- t > 0.
empty_link(t,L,0) :- &sum{ occupancy(t,L)} <= 0, link(L), t > 0.
empty_link(t,L,1) :- link(L), not empty_link(t,L,0), t > 0.
empty_link(t,outside,1) :- t > 0.
&sum{occupancy(t-1,L) ; D} = occupancy(t,L) :- delta(t,I+O,L,D), last_delta_out(O,L), last_delta_in(I,L), t > 0.
&sum{ counter(t-1,L) ; D } = counter(t,L) :- delta(t,O,L,D), last_delta_in(O,L), goal_count(L,_), t > 0.

#program check(t).
:- &sum{counter(t,L) } < B, counter(0,L,_), bound(B), goal_count(L,_).
&maximize{counter(t,L) : goal_count(L,_)}.

#show. 
&show {counter(t,L) : goal_count(L,_)}.