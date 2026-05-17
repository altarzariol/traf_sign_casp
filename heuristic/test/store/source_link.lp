flow(L1,L2,R) :- L1 = link(wrac1,y,wrbc1), 
                 turnrate(stage(wrbc1,1),L1,L2,R).

sum(S) :- S = #sum{R : flow(L,G,R)}.

#show flow/3.
#show sum/1.