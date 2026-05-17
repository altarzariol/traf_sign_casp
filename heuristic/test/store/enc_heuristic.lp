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
%                                                  
%
%


num(M) :- M = #count{L1 : goal_count(L1,K)}.
%          %N = 1..M.
%          %L = link(J1,GL,J2),
%          %goal_count(L,K).

%num(N) :- M = #count{L1 : goal_count(L1,K)},
%          N = 1..M.

%n_cafe(N,link(wrbc1,b,wrcc1)) :- N = 3, num(N).
%
%n_cafe(N,L) :- L = link(J1,GL,J2), 
%               goal_count(L,K),
%               num(N).
%
%:- n_cafe(N1,L),
%   n_cafe(N2,L),
%   N1 != N2.

%1{n_cafe(N,L) : L = link(J1,GL,J2), goal_count(L,K)}1 :- num(N).
%1{n_cafe(N,L) : num(N)}1 :- L = link(J1,GL,J2), goal_count(L,K).
%n_cafe(0,link(broad,x,wrfc1)).
%n_cafe(1,link(wrac1,y,wrbc1)).
%n_cafe(2,link(wrbc1,b,wrcc1)).
%
%&sum{0} = h_cafe(L,T,0) :- L = link(broad,x,wrfc1),
%                           not goal_count(L,350),  
%                           T = 0..horizon.
%                                                 
%&sum{h_cafe(L1,T,N-1); K; -counter(T,L); -E} = h_cafe(L,T,N) :- L  = link(J1,GL,J2),
%                                                                L1 = link(J3,G2,J4),
%                                                                %L1 != L,
%                                                                goal_count(L,K),
%                                                                exp(L,E),
%                                                                n_cafe(N-1,L1),
%                                                                n_cafe(N,L),
%                                                                T = 0..horizon.



%------------------------------------------------------------------
#show  sol(T-1,S,A1,A) : change(J,C,T,A), configuration(J,C-1,_,A1), active(T-1,S), status(J,S).
&show {counter(horizon,L) : counter(0,L,_)}.
&show {h_cafe(T,L) : L = link(J1,GL,J2), goal_count(L,350), T = horizon/2}.
&show {h_cafe_tot(T) : T = horizon/2, num(2)}.
&show {h_cafe_tot1(T) : T = horizon/2, num(3)}.
&show {h_cafe_tot2(T) : T = horizon/2, num(4)}.
&show {h_cafe_tot3(T) : T = horizon/2, num(5)}.
%&show {h_cafe_tot(N,T,L) : h_cafe(N), L = link(J1,GL,J2), goal_count(L,350), T = 0..horizon}.
%&show{h_cafe(L,T,N) : L = link(J1,GL,J2), n_cafe(N,L), goal_count(L,350), T = 0..horizon}.
