%%% version without max_phase 

%%% entry_confinguration
long_rate_in(stage(J1,N),C,M*S) :-
goal_count(link(J1,GL,J2),_),
phase_limit(stage(J1,N),C,M),
M = #max{L : phase_limit(stage(J1,N),_,L)},
S = #sum{R : turnrate_gez(stage(J1,N),L2,link(J1,GL,J2),R)}.

max_rate_in(stage(J,N),C,M) :-
long_rate_in(stage(J,N),C,M),
M = #max{V : long_rate_in(stage(J,N),_,V)}.

optimal_conf_in(C,link(J1,GL,J2)) :- 
goal_count(link(J1,GL,J2),_),
max_rate_in(stage(J1,N),C,M),
#count{C1 : max_rate_in(stage(J1,N),C1,M)} = 1. 

promising_conf_1(J,C,A) :- 
configuration(J,C,_,A), 
optimal_conf_in(A,L).

%% exit_configuration
long_rate_out(stage(J2,N),C,M*S) :-
goal_count(link(J1,GL,J2),_),
phase_limit(stage(J2,N),C,M),
M = #max{L : phase_limit(stage(J2,N),_,L)},
S = #sum{R : turnrate_gez(stage(J2,N),link(J1,GL,J2),L2,R)}.

max_rate_out(stage(J,N),C,M) :-
long_rate_out(stage(J,N),C,M),
M = #max{V : long_rate_out(stage(J,N),_,V)}.

optimal_conf_out(C,link(J1,GL,J2)) :- 
goal_count(link(J1,GL,J2),_),
max_rate_out(stage(J2,N),C,M),
#count{C1 : max_rate_out(stage(J2,N),C1,M)} = 1. 

promising_conf_2(J,C,A) :- 
configuration(J,C,_,A), 
optimal_conf_out(A,L).

#heuristic change(J,C,T,A). [3, false]
#heuristic promising_conf_2(J,C,A). [1, true]
#heuristic promising_conf_1(J,C,A). [1, true]


%-------------------------------------------------------------

%#show long_rate_in/3.
%#show max_rate_in/3.
#show optimal_conf_in/2.
#show promising_conf_1/3.

%#show long_rate_out/3.
%#show max_rate_out/3.
#show optimal_conf_out/2.
#show promising_conf_2/3.

