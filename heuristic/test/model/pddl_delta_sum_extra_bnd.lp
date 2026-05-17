%%to laod
% -- constants.lp
% -- enc_conf.lp
% -- enc_delta.lp
%
% follows(J,L):
%    the junction J follows the link L
follows(J2, link(J1,L,J2)):- link(J1,L,J2). 
% precedes(J,L):
%    the junction J precedes the link L
precedes(J1, link(J1,L,J2)):- link(J1,L,J2). 

link(link(J1,L,J2)) :- link(J1,L,J2).

% in_ord(L,L1,N):
%    L1 is the Nth incoming link (sorted according to the lex-order) for the link L  
in_ord(L,L1,N) :- turnrate(_,L1,L,_), N = #count{L2 : turnrate(_,L2,L,_), L2 <= L1}.

% out_ord(L,L1,L):
%    L1 is the Nth outgoing link (sorted according to the lex-order) for the link L 
out_ord(L,L1,N) :- turnrate(_,L,L1,_), N = #count{L2 : turnrate(_,L,L2,_), L2 <= L1}.


% full_link(T,L,0) -> the link L at time T is full
% full_link(T,L,1) -> the link L at time T is not full
% Alternative 1
%{full_link(T,L,0)} :- link(L), time(T).
%&sum{ occupancy(T,L);0 } > C:- full_link(T,L,0), capacity(L,C).
%&sum{ occupancy(T,L);0 } <= C:- full_link(T,L,1), capacity(L,C).
% Alternative 2
full_link(T,L,0) :- &sum{ occupancy(T,L) } >= C, time(T), capacity(L,C).
full_link(T,L,1) :- time(T), link(L), capacity(L,_), not full_link(T,L,0).

full_link(0,L,0) :- link(L), initial_occ(L,O), capacity(L,C), O>=C.
full_link(0,L,1) :- link(L), initial_occ(L,O), capacity(L,C), O<C.
full_link(0..horizon,L,1) :- link(L), not capacity(L,_).
full_link(0..horizon,outside,1).


% empty_link(T,L,0) -> the link L at time T is empty
% empty_link(T,L,1) -> the link L at time T is not empty
% Alternative 1
%{empty_link(T,L,0)} :- time(T), link(L).
%&sum{ occupancy(T,L);0 } < 99999 :- empty_link(T,L,0).
%&sum{ occupancy(T,L); 0} >= 100000 :- empty_link(T,L,1).
% Alternative 2
empty_link(T,L,0) :- &sum{ occupancy(T,L)} <= 0, time(T), link(L).
empty_link(T,L,1) :- time(T), link(L), not empty_link(T,L,0).

empty_link(0,L,1) :- link(L), initial_occ(L,O),  O>0.
empty_link(0,L,0) :- link(L), initial_occ(L,O),  O<=0.
empty_link(0..horizon,outside,1).

% for the link L, there are N incoming link
last_delta_in(N,L) :- link(L), N=#count{L1 : in_ord(L,L1,M)}.
% for the link L, there are N outgoing link
last_delta_out(N,L) :- link(L), N=#count{L1 : out_ord(L,L1,M)}.

% -------------------------- OLD-ENCODING -----------------------------------------
%sum_in(L,0..M) :- status(J,S), precedes(J,L), M=#sum{T,L1 : turnrate(S,L1,L,T)}.
%sum_out(L,0..M) :- status(J,S), follows(J,L), M=#sum{T,L1 : turnrate(S,L,L1,T)}.
%
%max_in(L,I) :- link(L), sum_in(L,I), not sum_in(L,I+1).
%max_out(L,O) :- link(L), sum_out(L,O), not sum_out(L,O+1).
%domain(L,-O,C+I) :- capacity(L,C), max_in(L,I), max_out(L,O).
%
%&dom{Mi..Ma} = occupancy(T,L) :- domain(L,Mi,Ma), time(T).
%&dom{-2*Z..C} = occupancy(T,L) :- not domain(L,_,_), inf_cap(C), unit(Z), link(L), time(T).
% -------------------------- OLD-ENCODING -----------------------------------------

% -------------------------- NEW-ENCODING EXTRA-----------------------------------------
sum_in(L,M) :- status(J,S), precedes(J,L), M=#sum{T,L1 : turnrate(S,L1,L,T)}.
sum_out(L,M) :- status(J,S), follows(J,L), M=#sum{T,L1 : turnrate(S,L,L1,T)}.

max_in(L,M) :- link(L), M=#max{I : sum_in(L,I)}.
max_out(L,M) :- link(L), M=#max{I : sum_out(L,I)}.

&dom{-O..C+I} = occupancy(T,L) :- capacity(L,C), max_in(L,I), max_out(L,O), time(T).
&sum{-O} <= occupancy(T,L) :- link(L), max_out(L,O), time(T).
% -------------------------- NEW-ENCODING EXTRA-----------------------------------------

&sum{ D} = occupancy(0,L) :- initial_occ(L,D).
&sum{occupancy(T-1,L); I+O} = occupancy(T,L) :- 
time(T),
link(L),
I = #sum{R*E*F,L1 : precedes(J,L), status(J,S), active(T-1,S), in_ord(L,L1,N), turnrate_gez(S,L1,L,R), empty_link(T-1,L1,E), full_link(T-1,L,F)},
O = #sum{-R*E*F,L1 : follows(J,L), status(J,S), active(T-1,S), out_ord(L,L1,N), turnrate_gez(S,L,L1,R), empty_link(T-1,L,E), full_link(T-1,L1,F)}.

&sum{ D} = counter(0,L) :- counter(0,L,D).
&sum{counter(T-1,L) ; I} = counter(T,L) :- 
time(T),
link(L),
I = #sum{R*E*F,L1 : precedes(J,L), status(J,S), active(T-1,S), in_ord(L,L1,N), turnrate_gez(S,L1,L,R), empty_link(T-1,L1,E), full_link(T-1,L,F)}.

:- &sum{counter(horizon,L) } < B, counter(0,L,_), goal(B), B>0.
:- &sum{counter(horizon,L) : pddl_solution(L,_)} <= S, S=#sum{B,L : pddl_solution(L,B)}, pddl_solution(_,_).

%&maximize{counter(horizon,L) : counter(0,L,_)}.

#show.
#show  sol(T-1,S,A1,A) : change(J,C,T,A), configuration(J,C-1,_,A1), active(T-1,S), status(J,S).
&show {counter(horizon,L) : counter(0,L,_)}.
