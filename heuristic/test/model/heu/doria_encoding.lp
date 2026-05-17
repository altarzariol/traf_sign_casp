total_enter(L, A, S) :-
    counter(0, L, _),
    available_conf(J, A),
    turnrate(stage(J,_), _, L, _),
    S = #sum{ R*D, stage(J,N) :
        turnrate(stage(J,N), _, L, R),
        phase_limit(stage(J,N), A, D)}.

total_exit(L, A, S) :-
    counter(0, L, _),
    available_conf(J, A),
    turnrate(stage(J,_), L, _, _),
    S = #sum{ R*D, stage(J,N) :
    turnrate(stage(J,N), L, _, R),
    phase_limit(stage(J,N), A, D)}.
                
enter_exit_pairs(L, A1, A2, S) :- total_enter(L, A1, IN), total_exit(L, A2, OUT), S = IN + OUT, A1!=A2.

max_pair_sum(L, S) :- 
    counter(0,L,_), 
    S = #max { V,A1,A2 : enter_exit_pairs(L, A1, A2, V) }.

best_enter_exit_pair(L, A1, A2, S) :-
    enter_exit_pairs(L, A1, A2, S),
    max_pair_sum(L, S).

appears_in_pair(A, L) :- best_enter_exit_pair(L, A, _, _).
appears_in_pair(A, L) :- best_enter_exit_pair(L, _, A, _).

pair_link_count(A, N) :-
    appears_in_pair(A, _),
    N = #count { L : appears_in_pair(A, L) }.

best_enter_count(L, N) :-
    best_enter_exit_pair(L, _, _, _),
    N = #max { C, A : best_enter_exit_pair(L, A, _, _), pair_link_count(A, C) }.

best_exit_count(L, N) :-
    best_enter_exit_pair(L, _, _, _),
    N = #max { C, A : best_enter_exit_pair(L, _, A, _), pair_link_count(A, C) }.

promising_enter(L, A) :-
    best_enter_exit_pair(L, A, _, _),
    pair_link_count(A, N),
    best_enter_count(L, N).

promising_exit(L, A) :-
    best_enter_exit_pair(L, _, A, _),
    pair_link_count(A, N),
    best_exit_count(L, N).

promising_conf(J, C, A) :-
    configuration(J, C, _, A),
    promising_enter(_, A).

promising_conf(J, C, A) :-
    configuration(J, C, _, A),
    promising_exit(_, A).

#heuristic change(J,C,T,A). [3, false]
#heuristic promising_conf(J, C, A). [1, true]
