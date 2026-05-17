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


%#heuristic change(J,C,T,A) : configuration(J,C,T,A), 0<C, not configuration(J,C-1,_,A). [-1, sign]
%#heuristic promising_conf_2(J,C,A) : &sum{h_cafe(T,link(wrac1,y,wrbc1))} < TS,
%                                     T = 250..horizon,
%                                     threshold(TS). 
%                                     [5, sign]

%#show  sol(T-1,S,A1,A) : change(J,C,T,A), configuration(J,C-1,_,A1), active(T-1,S), status(J,S).
%#show configuration/4.
#show promising_conf_2/3.
#show promising_conf_1/3.
#show change/4.

%#show max_phase_limit/2.
%#show max_stage/2.
%#show optimal_conf/2.
#show optimal_conf_fill/2.
#show optimal_conf_empty/2.

evaluate_heu :- &sum{h_cafe(horizon/2,L)} > TS,
                num(1),
                L = link(J1,GL,J2),
                goal_count(L,K),
                threshold(TS).

evaluate_heu :- &sum{h_cafe_tot(horizon/2)} > TS,
                num(2),
                threshold(TS).
                    
evaluate_heu :- &sum{h_cafe_tot1(horizon/2)} > TS,
                num(3),
                threshold(TS).

evaluate_heu :- &sum{h_cafe_tot2(horizon/2)} > TS,
                num(4),
                threshold(TS).

evaluate_heu :- &sum{h_cafe_tot3(horizon/2)} > TS,
                num(5),
                threshold(TS).

%#heuristic change(J,C,T,A): evaluate_heu. [3, false]

#heuristic promising_conf_1(J,C,A) : evaluate_heu.[1, true]
#heuristic promising_conf_2(J,C,A) : evaluate_heu.[1, true]

#heuristic promising_conf_1(J,C,A) : not evaluate_heu.[1, false]
#heuristic promising_conf_2(J,C,A) : not evaluate_heu.[1, false]

#show evaluate_heu.

% In this setting, first 'change' is evaluated to false: this implies that no change of 
% configuration will happen. In our case, for all the junctions in the corridor, if we
% start with the configuration 1 by default, the solver is able to generate only this
% type of configuration, because it is no possible to change them. 
% So, when it's time to evaluate true the atoms 'promising_conf_1/promising_conf_2', if
% the configuration(...) selected by the solver turns out to be at least one of the 
% optimal candidate with a stage of maximal limit,...
% ... if we force by heuristic these type of atoms to be true, then we probably 
% constrained which atoms 'confuguration' have to be the possible solution to maximise
% at the end the value of the 'counter'.
%#heuristic change(J,C,T,A). [3, false]
%#heuristic promising_conf_2(J,C,A). [1, true]
%#heuristic promising_conf_1(J,C,A). [1, true]

