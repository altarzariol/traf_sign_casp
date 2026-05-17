num(1..5).
costo(0..3).
mela(C,T) :- 
C = 1..2, 
T = 1..3.
pera(3,T) :- 
T = 1..3.

&sum{ C} = totale(T) :- 
C = 0, 
T = 0.

somma(S) :- S = #sum{ N : mela(N,T) }.

%&sum{totale(T-1) ; C; C1} = totale(T) :- 
%mela(C,T), pera(C1,T). %%%interesting!!!


&sum{totale(T-1) ; C} = totale(T) :- 
C = #sum{N : mela(N,T)}, 
mela(_,T).
pera(C1,T).

&sum{C} = duplex(C,T) :-
C = 0,
T = 0.

&sum{duplex(C-1,T-1); C} = duplex(C,T) :-
mela(C,T).

&sum{C} = somma_costo(C) :-
C = 0.

&sum{somma_costo(C-1); C} = somma_costo(C) :-
mela(C,_).

&sum{T} = prodotto(T) :-
T = 0.

&sum{prodotto(T-1); somma_costo(C)} = prodotto(T) :-
mela(_,T),
C = 2.




%&sum{ totale(T)} = aggiungi(T) :- 
%T = 3.
%&sum{aggiungi(T+3-1) ; C} = aggiungi(T+3) :- 
%pere(C,T).


%&sum{totale(T-1) ; C} = totale(T) :- frutta(C,T). 
%chip(1).
%chop(0).
%
%duplex((D;D1)) :- chip(D),chop(D1).
%&show {totale(T): chilo(T), T = 1..5}.
%costo_mela(2).
%costo_pere(3).
%frutta(C,T) :- mela(C,T).
%frutta(C,T) :- pere(C,T).