%%% version without max_phase 

%%% entry_confinguration
high_rate_in(stage(J1,N),C,L*S) :-
phase_limit(stage(J1,N),C,L),
goal_count(link(J1,GL,J2),_),
S = #sum{R : turnrate_gez(stage(J1,N),L2,link(J1,GL,J2),R)}.

max_rate_in(stage(J,N),C,M) :-
high_rate_in(stage(J,N),C,M),
M = #max{V : high_rate_in(stage(J,N),_,V)}.

optimal_conf_in(C,link(J1,GL,J2)) :- 
goal_count(link(J1,GL,J2),_),
max_rate_in(stage(J1,N),C,M),
#count{C1 : max_rate_in(stage(J1,N),C1,M)} = 1. 

promising_conf_1(J,C,A) :- 
change_in(L),
configuration(J,C,_,A), 
optimal_conf_in(A,L).

%% exit_configuration
high_rate_out(stage(J2,N),C,L*S) :-
phase_limit(stage(J2,N),C,L),
goal_count(link(J1,GL,J2),_),
S = #sum{R : turnrate_gez(stage(J2,N),link(J1,GL,J2),L2,R)}.

max_rate_out(stage(J,N),C,M) :-
high_rate_out(stage(J,N),C,M),
M = #max{V : high_rate_out(stage(J,N),_,V)}.

optimal_conf_out(C,link(J1,GL,J2)) :- 
goal_count(link(J1,GL,J2),_),
max_rate_out(stage(J2,N),C,M),
#count{C1 : max_rate_out(stage(J2,N),C1,M)} = 1. 

promising_conf_2(J,C,A) :- 
change_out(L),
configuration(J,C,_,A), 
optimal_conf_out(A,L).


%the occupancy is less than 10% of link's capacity
change_in(L) :- &sum{occupancy(horizon/2,L)} < (C*10/100),
capacity(L,C),
goal_count(L,_).


%the occupancy is greater than 90% of link's capacity
change_out(L) :- &sum{occupancy(horizon/2,L)} > (C*90/100),
capacity(L,C),
goal_count(L,_).

change_1 :- change_in(L).
change_2 :- change_out(L).

#heuristic promising_conf_1(J,C,A) : change_1.[1, true]
#heuristic promising_conf_2(J,C,A) : change_2.[1, true]

%-------------------------------------------------------------
%#show max_phase_limit/2.
%#show turn_in/2.
%#show high_rate_in/3.
%#show max_rate_in/3.
#show optimal_conf_in/2.
#show promising_conf_1/3.

%#show high_rate_out/3.
%#show max_rate_out/3.
#show optimal_conf_out/2.
#show promising_conf_2/3.

#show change_in/1.
#show change_out/1.

%#show goalcapacity(L,C) : goal_count(L,_), capacity(L,C) .
%&show {occupancy(0,L) : goal_count(L,_)}.

%---------------------------------------------------------------
%stage_value= stage_length * turnrate  
%* 
max_phase_limit(stage(J,N),M) :- 
stage(J,N), 
M = #max{L : phase_limit(stage(J,N),_,L)}.

turn_in(stage(J1,N),S) :- 
stage(J1,N),
goal_count(link(J1,GL,J2),_),
S = #sum{R : turnrate_gez(stage(J1,N),L2,link(J1,GL,J2),R)}.
*%
%*
%%% reduced version
high_rate_in(stage(J1,N),M*S) :-
stage(J1,N),
goal_count(link(J1,GL,J2),_),
M = #max{L : phase_limit(stage(J1,N),_,L)},
S = #sum{R : turnrate_gez(stage(J1,N),L2,link(J1,GL,J2),R)}.
*%

%*
high_rate_in(S,L*R) :- 
max_phase_limit(S,L),
turn_in(S,R).
*%