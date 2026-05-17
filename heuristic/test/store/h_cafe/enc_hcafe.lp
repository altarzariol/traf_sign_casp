%------------------------------------------------------------------
#const threshold_lim = bound/2.
threshold(TS) :- TS = threshold_lim.
%------------------------------------------------------------------
turn_in(J1,S,A,M) :- goal_count(link(J1,GL,J2),350),
                     configuration(J1,_,_,A),
                     S = stage(J1,_),
                     phase_limit(S,A,_),
                     M=#sum{R : turnrate_gez(S,_,link(J1,GL,J2),R)}.

green_time_in(J1,S,A,L) :- turn_in(J1,S1,A,M),
                           next(S1,S),
                           not end(S1),
                           phase_limit(S,A,L).
                      
exp_in(J1,S,A,E) :- turn_in(J1,S1,A,M),
                    green_time_in(J1,S,A,L),
                    next(S1,S),
                    E = M*L.                  

inflow(J1,A,I) :- goal_count(link(J1,GL,J2),350),
                  configuration(J1,_,_,A),
                  I = #sum{E : exp_in(J1,S,A,E)}.
%------------------------------------------------------------------

turn_out(J2,S,A,M) :- goal_count(link(J1,GL,J2),350),
                      configuration(J2,_,_,A),
                      S = stage(J2,_),
                      phase_limit(S,A,_),
                      M=#sum{R : turnrate_gez(S,link(J1,GL,J2),_,R)}.

green_time_out(J2,S,A,L) :- turn_out(J2,S1,A,M),
                            next(S1,S),
                            not end(S1),
                            phase_limit(S,A,L).
                      
exp_out(J2,S,A,E) :- turn_out(J2,S1,A,M),
                     green_time_out(J2,S,A,L),
                     next(S1,S),
                     E = M*L.                  

outflow(J2,A,O) :- goal_count(link(J1,GL,J2),350),
                   configuration(J2,_,_,A),
                   O = #sum{E : exp_out(J2,S,A,E)}.

%------------------------------------------------------------------

exp(L,I) :- goal_count(link(J1,GL,J2),350),
            L = link(J1,GL,J2),
            inflow(J1,A1,I),
            outflow(J2,A2,O),
            active_conf(T,J1,A1),
            active_conf(T,J2,A2),
            I <= O.

exp(L,O) :- goal_count(link(J1,GL,J2),350),
            L = link(J1,GL,J2),
            inflow(J1,A1,I),
            outflow(J2,A2,O),
            active_conf(T,J1,A1),
            active_conf(T,J2,A2),
            O <= I.
%------------------------------------------------------------------

num(M) :- M = #count{L1 : goal_count(L1,K)}.

&sum{KU; -counter(T,L); -E} = h_cafe(T,L) :- L = link(J1,GL,J2),
                                             goal_count(L,K),
                                             unit(U),
                                             KU = K*U,
                                             exp(L,E),
                                             T = 0..horizon.

&sum{h_cafe(T,L1); h_cafe(T,L2)} = h_cafe_tot(T) :-  L1 = link(J11,GL,J12),
                                                     L2 = link(J21,LG,J22),
                                                     L1 < L2,
                                                     num(2),
                                                     goal_count(L1,K),
                                                     goal_count(L2,K),         
                                                     T = 0..horizon.

&sum{h_cafe(T,L1); h_cafe(T,L2)
                 ; h_cafe(T,L3)} = h_cafe_tot1(T) :-  L1 = link(J11,GL,J12),
                                                      L2 = link(J21,LG,J22),
                                                      L3 = link(J31,G1,J32),
                                                      L1 < L2,
                                                      L2 < L3,
                                                      num(3),
                                                      goal_count(L1,K),
                                                      goal_count(L2,K), 
                                                      goal_count(L3,K),        
                                                      T = 0..horizon.   

&sum{h_cafe(T,L1); h_cafe(T,L2);
     h_cafe(T,L3); h_cafe(T,L4)} = h_cafe_tot2(T) :-  L1 = link(J11,GL,J12),
                                                      L2 = link(J21,LG,J22),
                                                      L3 = link(J31,G1,J32),
                                                      L4 = link(J41,G2,J42),
                                                      L1 < L2,
                                                      L2 < L3,
                                                      L3 < L4,
                                                      num(4),
                                                      goal_count(L1,K),
                                                      goal_count(L2,K), 
                                                      goal_count(L3,K),
                                                      goal_count(L4,K),        
                                                      T = 0..horizon.

&sum{h_cafe(T,L1); h_cafe(T,L2);
     h_cafe(T,L3); h_cafe(T,L4)
                 ; h_cafe(T,L5)} = h_cafe_tot3(T) :-  L1 = link(J11,GL,J12),
                                                      L2 = link(J21,LG,J22),
                                                      L3 = link(J31,G1,J32),
                                                      L4 = link(J41,G2,J42),
                                                      L5 = link(J51,G3,J52),
                                                      L1 < L2,
                                                      L2 < L3,
                                                      L3 < L4,
                                                      L4 < L5,
                                                      num(5),
                                                      goal_count(L1,K),
                                                      goal_count(L2,K), 
                                                      goal_count(L3,K),
                                                      goal_count(L4,K),
                                                      goal_count(L5,K),         
                                                      T = 0..horizon.

%-----------------------------------------------------------------------------

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

evaluate_heu :- &sum{h_cafe(horizon/2,L)} < TS,
                L = link(J1,GL,J2),
                goal_count(L,K),
                threshold(TS).

evaluate_heu :- &sum{h_cafe_tot(horizon/2)} < TS,
                num(2),
                threshold(TS).
                    
evaluate_heu :- &sum{h_cafe_tot1(horizon/2)} < TS,
                num(3),
                threshold(TS).

evaluate_heu :- &sum{h_cafe_tot2(horizon/2)} < TS,
                num(4),
                threshold(TS).

evaluate_heu :- &sum{h_cafe_tot3(horizon/2)} < TS,
                num(5),
                threshold(TS).

%#heuristic change(J,C,T,A): evaluate_heu. [3, false]

#heuristic promising_conf_1(J,C,A) : evaluate_heu.[1, sign]
#heuristic promising_conf_2(J,C,A) : evaluate_heu.[1, sign]

#heuristic promising_conf_1(J,C,A) : not evaluate_heu.[-1, sign]
#heuristic promising_conf_2(J,C,A) : not evaluate_heu.[-1, sign]


%-----------------------------------------------------------------------------

%&show {h_cafe(T,L) : L = link(J1,GL,J2), goal_count(L,350), T = 0..horizon}.
%&show {h_cafe_tot(T) : T = 0..horizon, num(2)}.
%&show {h_cafe_tot1(T) : T = 0..horizon, num(3)}.
%&show {h_cafe_tot2(T) : T = 0..horizon, num(4)}.
%&show {h_cafe_tot3(T) : T = 0..horizon, num(5)}.

&show {h_cafe(T,L) : L = link(J1,GL,J2), goal_count(L,350), T = horizon/2}.
&show {h_cafe_tot(T) : T = horizon/2, num(2)}.
&show {h_cafe_tot1(T) : T = horizon/2, num(3)}.
&show {h_cafe_tot2(T) : T = horizon/2, num(4)}.
&show {h_cafe_tot3(T) : T = horizon/2, num(5)}.

#show promising_conf_2/3.
#show promising_conf_1/3.
%#show change/4.

%-----------------------------------------------------------------------------

%&minimize{h_cafe(horizon/2,L) : L = link(J1,GL,J2), goal_count(L,K)}.