active_conf(0,wrac1,conf_wrac1_1).
active_conf(0,wrbc1,conf_wrbc1_1).
active_conf(0,wrcc1,conf_wrcc1_1).
active_conf(0,wrdc1,conf_wrdc1_1).
active_conf(0,wrec1,conf_wrec1_1).
active_conf(0,wrfc1,conf_wrfc1_1).

active(stage(wrac1,2)).
active(inter(wrbc1,2)).
active(stage(wrcc1,3)).
active(stage(wrdc1,1)).
active(stage(wrec1,1)).
active(stage(wrfc1,1)).

time(wrac1,13).
time(wrbc1,3).
time(wrcc1,4).
time(wrdc1,11).
time(wrec1,11).
time(wrfc1,20).

countcycle(wrac1,0).
countcycle(wrbc1,0).
countcycle(wrcc1,0).
countcycle(wrdc1,0).
countcycle(wrec1,0).
countcycle(wrfc1,0).

goal_count(link(wrac1,y,wrbc1),350).