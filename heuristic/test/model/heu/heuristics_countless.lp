max_phase_limit(stage(J,N),M) :- 
stage(J,N), 
M=#max{L : phase_limit(stage(J,N),_,L)}.
                                 
max_stage(C,stage(J,N)) :- 
available_conf(_,C), 
phase_limit(stage(J,N),C,L), 
max_phase_limit(stage(J,N),L). 
    
stage_fill(stage(J,N), L) :-  
turnrate(stage(J,N),_,L,_). 
stage_empty(stage(J,N), L) :-  
turnrate(stage(J,N),L,_,_). 

optimal_conf_empty(C,L) :- 
counter(0,L,_), 
stage_empty(S,L), 
max_stage(C,S).

optimal_conf_fill(C,L) :- 
counter(0,L,_), 
stage_fill(S,L), 
max_stage(C,S).

promising_conf_2(J,C,A) :- 
configuration(J,C,_,A), 
optimal_conf_empty(A,L).

promising_conf_1(J,C,A) :- 
configuration(J,C,_,A), 
optimal_conf_fill(A,L).

#heuristic change(J,C,T,A). [3, false]
#heuristic promising_conf_2(J,C,A). [1, true]
#heuristic promising_conf_1(J,C,A). [1, true]