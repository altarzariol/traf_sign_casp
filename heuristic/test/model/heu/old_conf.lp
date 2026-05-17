max_phase_limit(stage(J,N),M) :- stage(J,N), 
                                 M=#max{L : phase_limit(stage(J,N),_,L)}.
                                 
max_stage(C,stage(J,N)) :- available_conf(_,C), 
                           phase_limit(stage(J,N),C,L), 
                           max_phase_limit(stage(J,N),L). 
    

optimal_conf(C,stage(J,N)) :- max_stage(C,stage(J,N)),
                              #count{C1 : max_stage(C1,stage(J,N))}=1. 

stage_fill(stage(J,N), L) :- turnrate(stage(J,N),_,L,_). 
stage_empty(stage(J,N), L) :- turnrate(stage(J,N),L,_,_). 

optimal_conf_empty(C,L) :- counter(0,L,_), 
                           stage_empty(S,L), 
                           optimal_conf(C,S).

optimal_conf_fill(C,L) :- counter(0,L,_), 
                          stage_fill(S,L), 
                          optimal_conf(C,S).

promising_conf_2(J,C,A) :- configuration(J,C,_,A), 
                           optimal_conf_empty(A,L).

promising_conf_1(J,C,A) :- configuration(J,C,_,A),
                           optimal_conf_fill(A,L).


#show promising_conf_2/3.
#show promising_conf_1/3.

%#show max_phase_limit/2.
%#show max_stage/2.
%#show optimal_conf/2.
#show optimal_conf_fill/2.
#show optimal_conf_empty/2.