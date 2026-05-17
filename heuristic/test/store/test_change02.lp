max_phase_limit(stage(J,N),M) :- stage(J,N), 
                                 M=#max{L : phase_limit(stage(J,N),_,L)}.
                                 
max_stage(C,stage(J,N)) :- available_conf(_,C), 
                           phase_limit(stage(J,N),C,L), 
                           max_phase_limit(stage(J,N),L). 
    

optimal_conf(C,stage(J,N)) :- max_stage(C,stage(J,N)),
                              #count{C1 : max_stage(C1,stage(J,N))}=1. 
                             

#show max_phase_limit/2.
#show max_stage/2.
#show optimal_conf/2.
