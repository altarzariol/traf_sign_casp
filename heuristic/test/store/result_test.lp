inflow(wrac1,conf_wrac1_1, 895020)

green_time(wrac1,inter(wrac1,1),conf_wrac1_1,5) 
green_time(wrac1,inter(wrac1,2),conf_wrac1_1,6) 
green_time(wrac1,inter(wrac1,3),conf_wrac1_1,5) 
green_time(wrac1,inter(wrac1,4),conf_wrac1_1,5) 

turn_in(wrac1,stage(wrac1,1),conf_wrac1_1,65600) 
turn_in(wrac1,stage(wrac1,2),conf_wrac1_1,28820) 
turn_in(wrac1,stage(wrac1,3),conf_wrac1_1,53820) 
turn_in(wrac1,stage(wrac1,4),conf_wrac1_1,25000)

exp_in(wrac1,inter(wrac1,1),conf_wrac1_1,328000) 
exp_in(wrac1,inter(wrac1,2),conf_wrac1_1,172920) 
exp_in(wrac1,inter(wrac1,3),conf_wrac1_1,269100) 
exp_in(wrac1,inter(wrac1,4),conf_wrac1_1,125000) 

%-----------------------------------------------

outflow(wrbc1,conf_wrbc1_1,1270800) 

exp_out(wrac1,inter(wrbc1,1),conf_wrbc1_1,423600)
exp_out(wrac1,inter(wrbc1,2),conf_wrbc1_1,0) 
exp_out(wrac1,inter(wrbc1,3),conf_wrbc1_1,423600) 
exp_out(wrac1,inter(wrbc1,4),conf_wrbc1_1,0) 
exp_out(wrac1,inter(wrbc1,5),conf_wrbc1_1,847200) 

green_time_out(wrac1,inter(wrbc1,1),conf_wrbc1_1,6) 
green_time_out(wrac1,inter(wrbc1,2),conf_wrbc1_1,12) 
green_time_out(wrac1,inter(wrbc1,3),conf_wrbc1_1,6) 
green_time_out(wrac1,inter(wrbc1,4),conf_wrbc1_1,7) 
green_time_out(wrac1,inter(wrbc1,5),conf_wrbc1_1,12) 

turn_out(wrac1,stage(wrbc1,1),conf_wrbc1_1,70600) 
turn_out(wrac1,stage(wrbc1,2),conf_wrbc1_1,0) 
turn_out(wrac1,stage(wrbc1,3),conf_wrbc1_1,70600) 
turn_out(wrac1,stage(wrbc1,4),conf_wrbc1_1,0) 
turn_out(wrac1,stage(wrbc1,5),conf_wrbc1_1,70600)


%-------------------------------------------------------

exp(link(wrac1,y,wrbc1),895020)

%---------------------without cofiguration(J,0,0,A)------

exp(link(wrac1,y,wrbc1),895020) 

inflow(wrac1,conf_wrac1_1,895020) 
outflow(wrbc1,conf_wrbc1_1,1270800) 

exp_in(wrac1,inter(wrac1,1),conf_wrac1_1,328000) 
exp_in(wrac1,inter(wrac1,2),conf_wrac1_1,172920)
exp_in(wrac1,inter(wrac1,3),conf_wrac1_1,269100) 
exp_in(wrac1,inter(wrac1,4),conf_wrac1_1,125000) 

exp_out(wrbc1,inter(wrbc1,1),conf_wrbc1_1,423600)
exp_out(wrbc1,inter(wrbc1,2),conf_wrbc1_1,0) 
exp_out(wrbc1,inter(wrbc1,3),conf_wrbc1_1,423600) 
exp_out(wrbc1,inter(wrbc1,4),conf_wrbc1_1,0) 
exp_out(wrbc1,inter(wrbc1,5),conf_wrbc1_1,847200) 

green_time_in(wrac1,inter(wrac1,1),conf_wrac1_1,5)
green_time_in(wrac1,inter(wrac1,2),conf_wrac1_1,6) 
green_time_in(wrac1,inter(wrac1,3),conf_wrac1_1,5) 
green_time_in(wrac1,inter(wrac1,4),conf_wrac1_1,5) 

green_time_out(wrbc1,inter(wrbc1,1),conf_wrbc1_1,6) 
green_time_out(wrbc1,inter(wrbc1,2),conf_wrbc1_1,12) 
green_time_out(wrbc1,inter(wrbc1,3),conf_wrbc1_1,6) 
green_time_out(wrbc1,inter(wrbc1,4),conf_wrbc1_1,7) 
green_time_out(wrbc1,inter(wrbc1,5),conf_wrbc1_1,12) 

turn_in(wrac1,stage(wrac1,1),conf_wrac1_1,65600) 
turn_in(wrac1,stage(wrac1,2),conf_wrac1_1,28820) 
turn_in(wrac1,stage(wrac1,3),conf_wrac1_1,53820) 
turn_in(wrac1,stage(wrac1,4),conf_wrac1_1,25000) 

turn_out(wrbc1,stage(wrbc1,1),conf_wrbc1_1,70600) 
turn_out(wrbc1,stage(wrbc1,2),conf_wrbc1_1,0) 
turn_out(wrbc1,stage(wrbc1,3),conf_wrbc1_1,70600) 
turn_out(wrbc1,stage(wrbc1,4),conf_wrbc1_1,0) 
turn_out(wrbc1,stage(wrbc1,5),conf_wrbc1_1,70600)
 
%-----------one change of configuration------------------

exp(link(wrac1,y,wrbc1),895020) 

inflow(wrac1,conf_wrac1_1,895020) 
inflow(wrac1,conf_wrac1_6,895020) 

outflow(wrbc1,conf_wrbc1_1,1270800) 

exp_in(wrac1,inter(wrac1,1),conf_wrac1_1,328000) 
exp_in(wrac1,inter(wrac1,1),conf_wrac1_6,328000) 
exp_in(wrac1,inter(wrac1,2),conf_wrac1_1,172920) 
exp_in(wrac1,inter(wrac1,2),conf_wrac1_6,172920) 
exp_in(wrac1,inter(wrac1,3),conf_wrac1_1,269100) 
exp_in(wrac1,inter(wrac1,3),conf_wrac1_6,269100) 
exp_in(wrac1,inter(wrac1,4),conf_wrac1_1,125000) 
exp_in(wrac1,inter(wrac1,4),conf_wrac1_6,125000) 

exp_out(wrbc1,inter(wrbc1,1),conf_wrbc1_1,423600) 
exp_out(wrbc1,inter(wrbc1,2),conf_wrbc1_1,0) 
exp_out(wrbc1,inter(wrbc1,3),conf_wrbc1_1,423600) 
exp_out(wrbc1,inter(wrbc1,4),conf_wrbc1_1,0) 
exp_out(wrbc1,inter(wrbc1,5),conf_wrbc1_1,847200) 

green_time_in(wrac1,inter(wrac1,1),conf_wrac1_1,5) 
green_time_in(wrac1,inter(wrac1,1),conf_wrac1_6,5) 
green_time_in(wrac1,inter(wrac1,2),conf_wrac1_1,6) 
green_time_in(wrac1,inter(wrac1,2),conf_wrac1_6,6) 
green_time_in(wrac1,inter(wrac1,3),conf_wrac1_1,5) 
green_time_in(wrac1,inter(wrac1,3),conf_wrac1_6,5) 
green_time_in(wrac1,inter(wrac1,4),conf_wrac1_1,5) 
green_time_in(wrac1,inter(wrac1,4),conf_wrac1_6,5) 

green_time_out(wrbc1,inter(wrbc1,1),conf_wrbc1_1,6) 
green_time_out(wrbc1,inter(wrbc1,2),conf_wrbc1_1,12) 
green_time_out(wrbc1,inter(wrbc1,3),conf_wrbc1_1,6) 
green_time_out(wrbc1,inter(wrbc1,4),conf_wrbc1_1,7) 
green_time_out(wrbc1,inter(wrbc1,5),conf_wrbc1_1,12) 

sol(385,inter(wrac1,4),conf_wrac1_1,conf_wrac1_6) 
sol(702,inter(wrdc1,4),conf_wrdc1_1,conf_wrdc1_6) 
sol(740,inter(wrec1,4),conf_wrec1_1,conf_wrec1_3) 

turn_in(wrac1,stage(wrac1,1),conf_wrac1_1,65600) 
turn_in(wrac1,stage(wrac1,1),conf_wrac1_6,65600) 
turn_in(wrac1,stage(wrac1,2),conf_wrac1_1,28820) 
turn_in(wrac1,stage(wrac1,2),conf_wrac1_6,28820) 
turn_in(wrac1,stage(wrac1,3),conf_wrac1_1,53820) 
turn_in(wrac1,stage(wrac1,3),conf_wrac1_6,53820) 
turn_in(wrac1,stage(wrac1,4),conf_wrac1_1,25000) 
turn_in(wrac1,stage(wrac1,4),conf_wrac1_6,25000) 

turn_out(wrbc1,stage(wrbc1,1),conf_wrbc1_1,70600) 
turn_out(wrbc1,stage(wrbc1,2),conf_wrbc1_1,0) 
turn_out(wrbc1,stage(wrbc1,3),conf_wrbc1_1,70600) 
turn_out(wrbc1,stage(wrbc1,4),conf_wrbc1_1,0) 
turn_out(wrbc1,stage(wrbc1,5),conf_wrbc1_1,70600)

%-------------------------------------------------------

exp(link(wrac1,y,wrbc1),895020) 

sol(385,inter(wrac1,4),conf_wrac1_1,conf_wrac1_6) 
sol(702,inter(wrdc1,4),conf_wrdc1_1,conf_wrdc1_6) 
sol(740,inter(wrec1,4),conf_wrec1_1,conf_wrec1_3)

h_cafe(385,link(wrac1,y,wrbc1))=-15309610
h_cafe(702,link(wrac1,y,wrbc1))=-26069650
h_cafe(740,link(wrac1,y,wrbc1))=-27506650

h_cafe(780,link(wrac1,y,wrbc1))=-28739050
counter(780,link(wrac1,y,wrbc1))=27844380