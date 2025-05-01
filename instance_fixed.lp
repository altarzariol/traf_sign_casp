% controllable(J): the solver can change the configuration of junction J
controllable(wrac1).
controllable(wrbc1).
controllable(wrcc1).
controllable(wrdc1).
controllable(wrec1).
controllable(wrfc1).

% contains(J,S): junction J contains stage S
stage(wrac1,1).
stage(wrac1,2).
stage(wrac1,3).
stage(wrac1,4).
stage(wrbc1,1).
stage(wrbc1,2).
stage(wrbc1,3).
stage(wrbc1,4).
stage(wrbc1,5).
stage(wrcc1,1).
stage(wrcc1,2).
stage(wrcc1,3).
stage(wrcc1,4).
stage(wrcc1,5).
stage(wrcc1,6).
stage(wrdc1,1).
stage(wrdc1,2).
stage(wrdc1,3).
stage(wrdc1,4).
stage(wrec1,1).
stage(wrec1,2).
stage(wrec1,3).
stage(wrec1,4).
stage(wrfc1,1).
stage(wrfc1,2).
stage(wrfc1,3).

inter(J,N) :- stage(J,N).

status(J,inter(J,N)) :- inter(J,N).
status(J,stage(J,N)) :- stage(J,N).


% interlimit(S,I,L): the intergreen time for stage S is L seconds (uniquely identified with I)
interlimit(inter(wrac1,1),5).
interlimit(inter(wrac1,2),6).
interlimit(inter(wrac1,3),5).
interlimit(inter(wrac1,4),5).
interlimit(inter(wrbc1,1),6).
interlimit(inter(wrbc1,2),12).
interlimit(inter(wrbc1,3),6).
interlimit(inter(wrbc1,4),7).
interlimit(inter(wrbc1,5),12).
interlimit(inter(wrcc1,1),6).
interlimit(inter(wrcc1,2),8).
interlimit(inter(wrcc1,3),8).
interlimit(inter(wrcc1,4),11).
interlimit(inter(wrcc1,5),3).
interlimit(inter(wrcc1,6),2).
interlimit(inter(wrdc1,1),8).
interlimit(inter(wrdc1,2),8).
interlimit(inter(wrdc1,3),6).
interlimit(inter(wrdc1,4),7).
interlimit(inter(wrec1,1),3).
interlimit(inter(wrec1,2),7).
interlimit(inter(wrec1,3),7).
interlimit(inter(wrec1,4),7).
interlimit(inter(wrfc1,1),5).
interlimit(inter(wrfc1,2),9).
interlimit(inter(wrfc1,3),8).

phase_limit(inter(J,N),A,T) :- interlimit(inter(J,N),T), available_conf(J,A).


next(stage(J,N),inter(J,N)) :- stage(J,N), inter(J,N).
next(inter(J,N),stage(J,N+1)) :- inter(J,N), not end(inter(J,N)).
next(inter(J,N),stage(J,1)) :- inter(J,N), end(inter(J,N)).

% end(J,S): the cycle for junction J ends after (intergreen time of) stage S
end(inter(wrac1,4)).
end(inter(wrbc1,5)).
end(inter(wrcc1,6)).
end(inter(wrdc1,4)).
end(inter(wrec1,4)).
end(inter(wrfc1,3)).

%available_conf(J,C): the configuration C can be selected for junction C 
available_conf(wrac1,conf_wrac1_1).
available_conf(wrac1,conf_wrac1_2).
available_conf(wrac1,conf_wrac1_3).
available_conf(wrac1,conf_wrac1_4).
available_conf(wrac1,conf_wrac1_5).
available_conf(wrac1,conf_wrac1_6).
available_conf(wrbc1,conf_wrbc1_1).
available_conf(wrbc1,conf_wrbc1_2).
available_conf(wrbc1,conf_wrbc1_3).
available_conf(wrbc1,conf_wrbc1_4).
available_conf(wrbc1,conf_wrbc1_5).
available_conf(wrbc1,conf_wrbc1_6).
available_conf(wrcc1,conf_wrcc1_1).
available_conf(wrcc1,conf_wrcc1_2).
available_conf(wrcc1,conf_wrcc1_3).
available_conf(wrcc1,conf_wrcc1_4).
available_conf(wrcc1,conf_wrcc1_5).
available_conf(wrcc1,conf_wrcc1_6).
available_conf(wrdc1,conf_wrdc1_1).
available_conf(wrdc1,conf_wrdc1_2).
available_conf(wrdc1,conf_wrdc1_3).
available_conf(wrdc1,conf_wrdc1_4).
available_conf(wrdc1,conf_wrdc1_5).
available_conf(wrdc1,conf_wrdc1_6).
available_conf(wrec1,conf_wrec1_1).
available_conf(wrec1,conf_wrec1_2).
available_conf(wrec1,conf_wrec1_3).
available_conf(wrec1,conf_wrec1_4).
available_conf(wrec1,conf_wrec1_5).
available_conf(wrec1,conf_wrec1_6).
available_conf(wrfc1,conf_wrfc1_1).
available_conf(wrfc1,conf_wrfc1_2).
available_conf(wrfc1,conf_wrfc1_3).
available_conf(wrfc1,conf_wrfc1_4).
available_conf(wrfc1,conf_wrfc1_5).
available_conf(wrfc1,conf_wrfc1_6).


% link that are observed for the goal
counter(0,L,0) :- goal_count(L,_).


link(wrac1,x,wrbc1). 
link(wrac1,m,stand). 
link(wrac1,y,wrbc1). 
link(wrac1,z,hsac1). 
link(wrac1,n,firth). 
link(wrbc1,b,wrcc1). 
link(wrbc1,r,silve). 
link(wrbc1,a,wrac1). 
link(wrbc1,b,wrac1). 
link(wrbc1,s,somer). 
link(wrcc1,x,wrdc1). 
link(wrcc1,w,wrdc1). 
link(wrcc1,z,wrbc1). 
link(wrdc1,b,wrec1). 
link(wrdc1,l,absou). 
link(wrdc1,a,wrcc1). 
link(wrdc1,q,abnor). 
link(wrec1,z,wrdc1). 
link(wrec1,y,wrdc1). 
link(wrec1,y,wrfc1). 
link(wrfc1,a,wrec1). 
link(wrfc1,r,broad). 
link(wrfc1,t,wakef). 
link(hsac3,c,wrac1). 
link(stand,f,wrac1). 
link(firth,d,wrac1). 
link(silve,w,wrbc1). 
link(somer,v,wrbc1). 
link(smith,c,wrcc1). 
link(abnor,v,wrdc1). 
link(oldwa,c,wrec1). 
link(oldwa,d,wrec1). 
link(wakef,z,wrfc1). 
link(broad,x,wrfc1).


outside(J) :- link(J,_,_), not controllable(J).
outside(J) :- link(_,_,J), not controllable(J).
% the flow from outside is always active
active(0..horizon,stage(outside,1)).
status(J,stage(outside,1)) :- outside(J).

% set inital status: avoid input where the time in a phase is >= the limit
% if so, then shift to the beginning of the next phase
over_limit(J) :- active(S), active_conf(0,J,A),status(J,S), time(J,TS), phase_limit(S,A,L), L<=TS.

active(0,S) :- active(S), status(J,S), not over_limit(J). 
active(0,S1) :- active(S), status(J,S), over_limit(J), next(S,S1). 

time(0,J,TS) :- time(J,TS) , not over_limit(J). 
time(0,J,0) :- time(J,TS), over_limit(J). 

% consider the first cycle as completed only if the computation starts before the last stage
countcycle(0,J,C-1) :- active(0,S), status(J,S), end(S), countcycle(J,C). 
countcycle(0,J,C-1) :- active(0,S), status(J,S), next(S,S1), end(S1), countcycle(J,C).  
countcycle(0,J,C) :- active(0,S), status(J,S), next(S,S1), not end(S1),not end(S), countcycle(J,C). 
