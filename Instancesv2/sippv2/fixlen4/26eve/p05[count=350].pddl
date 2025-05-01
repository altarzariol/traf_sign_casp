(define (problem huddersfield)
(:domain urbantraffic)
(:objects
wrac1 wrbc1 wrcc1 wrdc1 wrec1 wrfc1 - junction
hsac3_c_wrac1 wrac1_z_hsac1 wrac1_y_wrbc1 wrac1_m_stand stand_f_wrac1 wrac1_n_firth firth_d_wrac1 wrac1_x_wrbc1 wrbc1_a_wrac1 wrbc1_b_wrcc1 wrbc1_r_silve silve_w_wrbc1 wrbc1_s_somer somer_v_wrbc1 wrbc1_b_wrac1 wrcc1_z_wrbc1 wrcc1_x_wrdc1 smith_c_wrcc1 wrcc1_w_wrdc1 wrdc1_a_wrcc1 wrdc1_b_wrec1 wrdc1_q_abnor wrdc1_l_absou abnor_v_wrdc1 wrec1_z_wrdc1 wrec1_y_wrfc1 oldwa_c_wrec1 wrec1_y_wrdc1 oldwa_d_wrec1 wakef_z_wrfc1 wrfc1_a_wrec1 wrfc1_r_broad broad_x_wrfc1 wrfc1_t_wakef outside - link
wrac1_stage1 wrac1_stage2 wrac1_stage3 wrac1_stage4 wrbc1_stage1 wrbc1_stage2 wrbc1_stage3 wrbc1_stage4 wrbc1_stage5 wrcc1_stage1 wrcc1_stage2 wrcc1_stage3 wrcc1_stage4 wrcc1_stage5 wrcc1_stage6 wrdc1_stage1 wrdc1_stage2 wrdc1_stage3 wrdc1_stage4 wrec1_stage1 wrec1_stage2 wrec1_stage3 wrec1_stage4 wrfc1_stage1 wrfc1_stage2 wrfc1_stage3 fake - stage
conf_wrac1_1 conf_wrac1_2 conf_wrac1_3 conf_wrac1_4 conf_wrac1_5 conf_wrac1_6 conf_wrbc1_1 conf_wrbc1_2 conf_wrbc1_3 conf_wrbc1_4 conf_wrbc1_5 conf_wrbc1_6 conf_wrcc1_1 conf_wrcc1_2 conf_wrcc1_3 conf_wrcc1_4 conf_wrcc1_5 conf_wrcc1_6 conf_wrdc1_1 conf_wrdc1_2 conf_wrdc1_3 conf_wrdc1_4 conf_wrdc1_5 conf_wrdc1_6 conf_wrec1_1 conf_wrec1_2 conf_wrec1_3 conf_wrec1_4 conf_wrec1_5 conf_wrec1_6 conf_wrfc1_1 conf_wrfc1_2 conf_wrfc1_3 conf_wrfc1_4 conf_wrfc1_5 conf_wrfc1_6 - configuration
)
(:init
(controllable wrac1)
(controllable wrbc1)
(controllable wrcc1)
(controllable wrdc1)
(controllable wrec1)
(controllable wrfc1)
(= (capacity outside) 100000.0)
(= (capacity hsac3_c_wrac1)   55.0)
(= (capacity wrac1_z_hsac1)   100000.0)
(= (capacity wrac1_y_wrbc1)   55.5)
(= (capacity wrac1_m_stand)   100000.0)
(= (capacity stand_f_wrac1)   54.0)
(= (capacity wrac1_n_firth)   100000.0)
(= (capacity firth_d_wrac1)   27.67)
(= (capacity wrac1_x_wrbc1)   24.5)
(= (capacity wrbc1_a_wrac1)   85.0)
(= (capacity wrbc1_b_wrcc1)   30.66)
(= (capacity wrbc1_r_silve)  100000.0)
(= (capacity silve_w_wrbc1)  13.67)
(= (capacity wrbc1_s_somer)  100000.0)
(= (capacity somer_v_wrbc1)  55.5)
(= (capacity wrbc1_b_wrac1)  12.0)
(= (capacity wrcc1_z_wrbc1)  56.0)
(= (capacity wrcc1_x_wrdc1)  93.3)
(= (capacity smith_c_wrcc1)  14.13)
(= (capacity wrdc1_a_wrcc1)  42.0)
(= (capacity wrdc1_b_wrec1)  26.67)
(= (capacity wrdc1_q_abnor)  100000.0)
(= (capacity wrcc1_w_wrdc1)   5.0)
(= (capacity wrdc1_l_absou)   100000.0)
(= (capacity abnor_v_wrdc1)   148.33)
(= (capacity wrec1_z_wrdc1)   28.67)
(= (capacity wrec1_y_wrfc1)   13.0)
(= (capacity oldwa_c_wrec1)   12.33)
(= (capacity wrec1_y_wrdc1)   6.33)
(= (capacity oldwa_d_wrec1)   13.33)
(= (capacity wakef_z_wrfc1)   24.0)
(= (capacity wrfc1_a_wrec1)   9.66)
(= (capacity wrfc1_r_broad)   100000.0)
(= (capacity broad_x_wrfc1)   13.67)
(= (capacity wrfc1_t_wakef)   100000.0)

(contains wrac1 wrac1_stage1)
(contains wrac1 wrac1_stage2)
(contains wrac1 wrac1_stage3)
(contains wrac1 wrac1_stage4)
(contains wrbc1 wrbc1_stage1)
(contains wrbc1 wrbc1_stage2)
(contains wrbc1 wrbc1_stage3)
(contains wrbc1 wrbc1_stage4)
(contains wrbc1 wrbc1_stage5)
(contains wrcc1 wrcc1_stage1)
(contains wrcc1 wrcc1_stage2)
(contains wrcc1 wrcc1_stage3)
(contains wrcc1 wrcc1_stage4)
(contains wrcc1 wrcc1_stage5)
(contains wrcc1 wrcc1_stage6)
(contains wrdc1 wrdc1_stage1)
(contains wrdc1 wrdc1_stage2)
(contains wrdc1 wrdc1_stage3)
(contains wrdc1 wrdc1_stage4)
(contains wrec1 wrec1_stage1)
(contains wrec1 wrec1_stage2)
(contains wrec1 wrec1_stage3)
(contains wrec1 wrec1_stage4)
(contains wrfc1 wrfc1_stage1)
(contains wrfc1 wrfc1_stage2)
(contains wrfc1 wrfc1_stage3)

(= (turnrate wrac1_stage1 hsac3_c_wrac1 wrac1_x_wrbc1) 0.129)
(= (turnrate wrac1_stage1 hsac3_c_wrac1 wrac1_m_stand) 0.3915)
(= (turnrate wrac1_stage1 hsac3_c_wrac1 wrac1_y_wrbc1) 0.656)
(= (turnrate wrac1_stage1 wrbc1_a_wrac1 wrac1_z_hsac1) 0.494)
(= (turnrate wrac1_stage1 wrbc1_a_wrac1 wrac1_n_firth) 0.447)
(= (turnrate wrac1_stage2 wrbc1_a_wrac1 wrac1_z_hsac1) 0.494)
(= (turnrate wrac1_stage2 wrbc1_a_wrac1 wrac1_n_firth) 0.447)
(= (turnrate wrac1_stage2 wrbc1_b_wrac1 wrac1_m_stand) 0.412)
(= (turnrate wrbc1_stage1 wrac1_y_wrbc1 wrbc1_b_wrcc1) 0.576)
(= (turnrate wrbc1_stage1 wrac1_y_wrbc1 wrbc1_r_silve) 0.13)
(= (turnrate wrbc1_stage1 wrcc1_z_wrbc1 wrbc1_a_wrac1) 1.05)
(= (turnrate wrbc1_stage1 wrcc1_z_wrbc1 wrbc1_b_wrac1) 0.1265)
(= (turnrate wrbc1_stage2 silve_w_wrbc1 wrbc1_a_wrac1) 0.3502)
(= (turnrate wrbc1_stage2 silve_w_wrbc1 wrbc1_b_wrac1) 0.061)
(= (turnrate wrbc1_stage3 wrac1_y_wrbc1 wrbc1_b_wrcc1) 0.576)
(= (turnrate wrbc1_stage3 wrac1_y_wrbc1 wrbc1_r_silve) 0.13)
(= (turnrate wrbc1_stage3 wrac1_x_wrbc1 wrbc1_s_somer) 0.412)
(= (turnrate wrbc1_stage3 somer_v_wrbc1 wrbc1_a_wrac1) 0.51)
(= (turnrate wrbc1_stage3 somer_v_wrbc1 wrbc1_b_wrac1) 0.0194)
(= (turnrate wrbc1_stage4 wrac1_x_wrbc1 wrbc1_s_somer) 0.412)
(= (turnrate wrbc1_stage4 somer_v_wrbc1 wrbc1_a_wrac1) 0.51)
(= (turnrate wrbc1_stage4 somer_v_wrbc1 wrbc1_b_wrac1) 0.0194)
(= (turnrate wrbc1_stage5 wrac1_y_wrbc1 wrbc1_b_wrcc1) 0.576)
(= (turnrate wrbc1_stage5 wrac1_y_wrbc1 wrbc1_r_silve) 0.13)
(= (turnrate wrbc1_stage5 wrac1_x_wrbc1 wrbc1_s_somer) 0.412)
(= (turnrate wrcc1_stage1 wrbc1_b_wrcc1 wrcc1_x_wrdc1) 0.447)
(= (turnrate wrcc1_stage1 wrbc1_b_wrcc1 wrcc1_w_wrdc1) 0.024)
(= (turnrate wrcc1_stage1 wrdc1_a_wrcc1 wrcc1_z_wrbc1) 0.82353)
(= (turnrate wrcc1_stage2 wrdc1_a_wrcc1 wrcc1_z_wrbc1) 0.82353)
(= (turnrate wrcc1_stage3 wrbc1_b_wrcc1 wrcc1_x_wrdc1) 0.447)
(= (turnrate wrcc1_stage3 wrbc1_b_wrcc1 wrcc1_w_wrdc1) 0.024)
(= (turnrate wrcc1_stage4 smith_c_wrcc1 wrcc1_z_wrbc1) 0.143)
(= (turnrate wrcc1_stage4 smith_c_wrcc1 wrcc1_x_wrdc1) 0.2636)
(= (turnrate wrcc1_stage4 smith_c_wrcc1 wrcc1_w_wrdc1) 0.064)
(= (turnrate wrcc1_stage5 smith_c_wrcc1 wrcc1_z_wrbc1) 0.143)
(= (turnrate wrcc1_stage5 smith_c_wrcc1 wrcc1_x_wrdc1) 0.2636)
(= (turnrate wrcc1_stage5 smith_c_wrcc1 wrcc1_w_wrdc1) 0.064)
(= (turnrate wrdc1_stage1 wrcc1_x_wrdc1 wrdc1_b_wrec1) 0.659)
(= (turnrate wrdc1_stage1 wrcc1_x_wrdc1 wrdc1_l_absou) 0.165)
(= (turnrate wrdc1_stage1 wrec1_z_wrdc1 wrdc1_a_wrcc1) 0.8)
(= (turnrate wrdc1_stage1 wrec1_z_wrdc1 wrdc1_q_abnor) 0.2)
(= (turnrate wrdc1_stage2 wrec1_z_wrdc1 wrdc1_a_wrcc1) 0.8)
(= (turnrate wrdc1_stage2 wrec1_z_wrdc1 wrdc1_q_abnor) 0.2)
(= (turnrate wrdc1_stage2 wrec1_y_wrdc1 wrdc1_l_absou) 0.353)
(= (turnrate wrdc1_stage3 abnor_v_wrdc1 wrdc1_a_wrcc1) 0.05)
(= (turnrate wrdc1_stage3 abnor_v_wrdc1 wrdc1_b_wrec1) 0.029)
(= (turnrate wrdc1_stage3 abnor_v_wrdc1 wrdc1_l_absou) 0.45)
(= (turnrate wrdc1_stage4 wrcc1_x_wrdc1 wrdc1_b_wrec1) 0.659)
(= (turnrate wrdc1_stage4 wrcc1_x_wrdc1 wrdc1_l_absou) 0.165)
(= (turnrate wrdc1_stage4 wrcc1_w_wrdc1 wrdc1_q_abnor) 0.353)
(= (turnrate wrec1_stage1 wrfc1_a_wrec1 wrec1_z_wrdc1) 0.808)
(= (turnrate wrec1_stage1 wrfc1_a_wrec1 wrec1_y_wrdc1) 0.016)
(= (turnrate wrec1_stage1 wrdc1_b_wrec1 wrec1_y_wrfc1) 0.824)
(= (turnrate wrec1_stage2 wrdc1_b_wrec1 wrec1_y_wrfc1) 0.824)
(= (turnrate wrec1_stage3 oldwa_c_wrec1 wrec1_z_wrdc1) 0.346)
(= (turnrate wrec1_stage3 oldwa_c_wrec1 wrec1_y_wrdc1) 0.007)
(= (turnrate wrec1_stage3 oldwa_d_wrec1 wrec1_y_wrfc1) 0.353)
(= (turnrate wrec1_stage4 wrfc1_a_wrec1 wrec1_z_wrdc1) 0.808)
(= (turnrate wrec1_stage4 wrfc1_a_wrec1 wrec1_y_wrdc1) 0.016)
(= (turnrate wrec1_stage4 oldwa_d_wrec1 wrec1_y_wrfc1) 0.353)
(= (turnrate wrfc1_stage1 wakef_z_wrfc1 wrfc1_a_wrec1) 0.765)
(= (turnrate wrfc1_stage1 wrec1_y_wrfc1 wrfc1_r_broad) 0.082)
(= (turnrate wrfc1_stage1 wrec1_y_wrfc1 wrfc1_t_wakef) 0.741)
(= (turnrate wrfc1_stage2 wrec1_y_wrfc1 wrfc1_r_broad) 0.082)
(= (turnrate wrfc1_stage2 wrec1_y_wrfc1 wrfc1_t_wakef) 0.741)
(= (turnrate wrfc1_stage3 broad_x_wrfc1 wrfc1_a_wrec1) 0.571)
(= (turnrate wrfc1_stage3 broad_x_wrfc1 wrfc1_t_wakef) 0.017)
(= (turnrate wrac1_stage3 firth_d_wrac1 wrac1_z_hsac1) 0.04)
(= (turnrate wrac1_stage3 firth_d_wrac1 wrac1_y_wrbc1) 0.25)
(= (turnrate wrac1_stage3 firth_d_wrac1 wrac1_x_wrbc1) 0.06)
(= (turnrate wrac1_stage3 firth_d_wrac1 wrac1_m_stand) 0.06) 
(= (turnrate wrac1_stage4 firth_d_wrac1 wrac1_z_hsac1) 0.04)
(= (turnrate wrac1_stage4 firth_d_wrac1 wrac1_y_wrbc1) 0.25)
(= (turnrate wrac1_stage4 firth_d_wrac1 wrac1_x_wrbc1) 0.06)
(= (turnrate wrac1_stage4 firth_d_wrac1 wrac1_m_stand) 0.06) 
(= (turnrate wrac1_stage2 stand_f_wrac1 wrac1_n_firth)  0.2) 
(= (turnrate wrac1_stage2 stand_f_wrac1 wrac1_y_wrbc1) 0.2882)
(= (turnrate wrac1_stage2 stand_f_wrac1 wrac1_x_wrbc1) 0.1)
(= (turnrate wrac1_stage3 stand_f_wrac1 wrac1_n_firth)  0.2) 
(= (turnrate wrac1_stage3 stand_f_wrac1 wrac1_y_wrbc1) 0.2882)
(= (turnrate wrac1_stage3 stand_f_wrac1 wrac1_x_wrbc1) 0.1)


;; CONF 1 PER WRAC1
(= (confgreentime wrac1_stage1 conf_wrac1_1) 40)
(= (confgreentime wrac1_stage2 conf_wrac1_1) 23)
(= (confgreentime wrac1_stage3 conf_wrac1_1) 17)
(= (confgreentime wrac1_stage4 conf_wrac1_1) 10)


;; CONF 2 PER WRAC1
(= (confgreentime wrac1_stage1 conf_wrac1_2) 45)
(= (confgreentime wrac1_stage2 conf_wrac1_2) 20)
(= (confgreentime wrac1_stage3 conf_wrac1_2) 15)
(= (confgreentime wrac1_stage4 conf_wrac1_2) 10)


;; CONF 3 PER WRAC1
(= (confgreentime wrac1_stage1 conf_wrac1_3) 25)
(= (confgreentime wrac1_stage2 conf_wrac1_3) 40)
(= (confgreentime wrac1_stage3 conf_wrac1_3) 15)
(= (confgreentime wrac1_stage4 conf_wrac1_3) 10)


;; CONF 4 PER WRAC1
(= (confgreentime wrac1_stage1 conf_wrac1_4) 37)
(= (confgreentime wrac1_stage2 conf_wrac1_4) 19)
(= (confgreentime wrac1_stage3 conf_wrac1_4) 24)
(= (confgreentime wrac1_stage4 conf_wrac1_4) 10)


;; CONF 5 PER WRAC1
(= (confgreentime wrac1_stage1 conf_wrac1_5) 32)
(= (confgreentime wrac1_stage2 conf_wrac1_5) 31)
(= (confgreentime wrac1_stage3 conf_wrac1_5) 17)
(= (confgreentime wrac1_stage4 conf_wrac1_5) 10)


;; CONF 6 PER WRAC1
(= (confgreentime wrac1_stage1 conf_wrac1_6) 36)
(= (confgreentime wrac1_stage2 conf_wrac1_6) 23)
(= (confgreentime wrac1_stage3 conf_wrac1_6) 21)
(= (confgreentime wrac1_stage4 conf_wrac1_6) 10)


;; CONF 1 PER WRBC1
(= (confgreentime wrbc1_stage1 conf_wrbc1_1) 39)
(= (confgreentime wrbc1_stage2 conf_wrbc1_1) 13)
(= (confgreentime wrbc1_stage3 conf_wrbc1_1) 38)
(= (confgreentime wrbc1_stage4 conf_wrbc1_1) 7)
(= (confgreentime wrbc1_stage5 conf_wrbc1_1) 7)


;; CONF 2 PER WRBC1
(= (confgreentime wrbc1_stage1 conf_wrbc1_2) 53)
(= (confgreentime wrbc1_stage2 conf_wrbc1_2) 13)
(= (confgreentime wrbc1_stage3 conf_wrbc1_2) 24)
(= (confgreentime wrbc1_stage4 conf_wrbc1_2) 7)
(= (confgreentime wrbc1_stage5 conf_wrbc1_2) 7)


;; CONF 3 PER WRBC1
(= (confgreentime wrbc1_stage1 conf_wrbc1_3) 23)
(= (confgreentime wrbc1_stage2 conf_wrbc1_3) 42)
(= (confgreentime wrbc1_stage3 conf_wrbc1_3) 25)
(= (confgreentime wrbc1_stage4 conf_wrbc1_3) 7)
(= (confgreentime wrbc1_stage5 conf_wrbc1_3) 7)


;; CONF 4 PER WRBC1
(= (confgreentime wrbc1_stage1 conf_wrbc1_4) 32)
(= (confgreentime wrbc1_stage2 conf_wrbc1_4) 15)
(= (confgreentime wrbc1_stage3 conf_wrbc1_4) 43)
(= (confgreentime wrbc1_stage4 conf_wrbc1_4) 7)
(= (confgreentime wrbc1_stage5 conf_wrbc1_4) 7)


;; CONF 5 PER WRBC1
(= (confgreentime wrbc1_stage1 conf_wrbc1_5) 36)
(= (confgreentime wrbc1_stage2 conf_wrbc1_5) 25)
(= (confgreentime wrbc1_stage3 conf_wrbc1_5) 29)
(= (confgreentime wrbc1_stage4 conf_wrbc1_5) 7)
(= (confgreentime wrbc1_stage5 conf_wrbc1_5) 7)


;; CONF 6 PER WRBC1
(= (confgreentime wrbc1_stage1 conf_wrbc1_6) 42)
(= (confgreentime wrbc1_stage2 conf_wrbc1_6) 18)
(= (confgreentime wrbc1_stage3 conf_wrbc1_6) 30)
(= (confgreentime wrbc1_stage4 conf_wrbc1_6) 7)
(= (confgreentime wrbc1_stage5 conf_wrbc1_6) 7)


;; CONF 1 PER WRCC1
(= (confgreentime wrcc1_stage1 conf_wrcc1_1) 51)
(= (confgreentime wrcc1_stage2 conf_wrcc1_1) 7)
(= (confgreentime wrcc1_stage3 conf_wrcc1_1) 17)
(= (confgreentime wrcc1_stage4 conf_wrcc1_1) 7)
(= (confgreentime wrcc1_stage5 conf_wrcc1_1) 22)
(= (confgreentime wrcc1_stage6 conf_wrcc1_1) 7)


;; CONF 2 PER WRCC1
(= (confgreentime wrcc1_stage1 conf_wrcc1_2) 55)
(= (confgreentime wrcc1_stage2 conf_wrcc1_2) 7)
(= (confgreentime wrcc1_stage3 conf_wrcc1_2) 17)
(= (confgreentime wrcc1_stage4 conf_wrcc1_2) 7)
(= (confgreentime wrcc1_stage5 conf_wrcc1_2) 18)
(= (confgreentime wrcc1_stage6 conf_wrcc1_2) 7)


;; CONF 3 PER WRCC1
(= (confgreentime wrcc1_stage1 conf_wrcc1_3) 26)
(= (confgreentime wrcc1_stage2 conf_wrcc1_3) 7)
(= (confgreentime wrcc1_stage3 conf_wrcc1_3) 33)
(= (confgreentime wrcc1_stage4 conf_wrcc1_3) 7)
(= (confgreentime wrcc1_stage5 conf_wrcc1_3) 31)
(= (confgreentime wrcc1_stage6 conf_wrcc1_3) 7)


;; CONF 4 PER WRCC1
(= (confgreentime wrcc1_stage1 conf_wrcc1_4) 43)
(= (confgreentime wrcc1_stage2 conf_wrcc1_4) 7)
(= (confgreentime wrcc1_stage3 conf_wrcc1_4) 22)
(= (confgreentime wrcc1_stage4 conf_wrcc1_4) 7)
(= (confgreentime wrcc1_stage5 conf_wrcc1_4) 25)
(= (confgreentime wrcc1_stage6 conf_wrcc1_4) 7)


;; CONF 5 PER WRCC1
(= (confgreentime wrcc1_stage1 conf_wrcc1_5) 38)
(= (confgreentime wrcc1_stage2 conf_wrcc1_5) 7)
(= (confgreentime wrcc1_stage3 conf_wrcc1_5) 26)
(= (confgreentime wrcc1_stage4 conf_wrcc1_5) 7)
(= (confgreentime wrcc1_stage5 conf_wrcc1_5) 26)
(= (confgreentime wrcc1_stage6 conf_wrcc1_5) 7)


;; CONF 6 PER WRCC1
(= (confgreentime wrcc1_stage1 conf_wrcc1_6) 49)
(= (confgreentime wrcc1_stage2 conf_wrcc1_6) 7)
(= (confgreentime wrcc1_stage3 conf_wrcc1_6) 18)
(= (confgreentime wrcc1_stage4 conf_wrcc1_6) 7)
(= (confgreentime wrcc1_stage5 conf_wrcc1_6) 23)
(= (confgreentime wrcc1_stage6 conf_wrcc1_6) 7)


;; CONF 1 PER WRDC1
(= (confgreentime wrdc1_stage1 conf_wrdc1_1) 39)
(= (confgreentime wrdc1_stage2 conf_wrdc1_1) 17)
(= (confgreentime wrdc1_stage3 conf_wrdc1_1) 18)
(= (confgreentime wrdc1_stage4 conf_wrdc1_1) 16)


;; CONF 2 PER WRDC1
(= (confgreentime wrdc1_stage1 conf_wrdc1_2) 43)
(= (confgreentime wrdc1_stage2 conf_wrdc1_2) 17)
(= (confgreentime wrdc1_stage3 conf_wrdc1_2) 15)
(= (confgreentime wrdc1_stage4 conf_wrdc1_2) 15)


;; CONF 3 PER WRDC1
(= (confgreentime wrdc1_stage1 conf_wrdc1_3) 22)
(= (confgreentime wrdc1_stage2 conf_wrdc1_3) 18)
(= (confgreentime wrdc1_stage3 conf_wrdc1_3) 22)
(= (confgreentime wrdc1_stage4 conf_wrdc1_3) 28)


;; CONF 4 PER WRDC1
(= (confgreentime wrdc1_stage1 conf_wrdc1_4) 33)
(= (confgreentime wrdc1_stage2 conf_wrdc1_4) 20)
(= (confgreentime wrdc1_stage3 conf_wrdc1_4) 21)
(= (confgreentime wrdc1_stage4 conf_wrdc1_4) 16)


;; CONF 5 PER WRDC1
(= (confgreentime wrdc1_stage1 conf_wrdc1_5) 26)
(= (confgreentime wrdc1_stage2 conf_wrdc1_5) 20)
(= (confgreentime wrdc1_stage3 conf_wrdc1_5) 24)
(= (confgreentime wrdc1_stage4 conf_wrdc1_5) 20)


;; CONF 6 PER WRDC1
(= (confgreentime wrdc1_stage1 conf_wrdc1_6) 39)
(= (confgreentime wrdc1_stage2 conf_wrdc1_6) 17)
(= (confgreentime wrdc1_stage3 conf_wrdc1_6) 19)
(= (confgreentime wrdc1_stage4 conf_wrdc1_6) 15)


;; CONF 1 PER WREC1
(= (confgreentime wrec1_stage1 conf_wrec1_1) 47)
(= (confgreentime wrec1_stage2 conf_wrec1_1) 5)
(= (confgreentime wrec1_stage3 conf_wrec1_1) 12)
(= (confgreentime wrec1_stage4 conf_wrec1_1) 6)


;; CONF 2 PER WREC1
(= (confgreentime wrec1_stage1 conf_wrec1_2) 48)
(= (confgreentime wrec1_stage2 conf_wrec1_2) 5)
(= (confgreentime wrec1_stage3 conf_wrec1_2) 12)
(= (confgreentime wrec1_stage4 conf_wrec1_2) 5)


;; CONF 3 PER WREC1
(= (confgreentime wrec1_stage1 conf_wrec1_3) 44)
(= (confgreentime wrec1_stage2 conf_wrec1_3) 4)
(= (confgreentime wrec1_stage3 conf_wrec1_3) 14)
(= (confgreentime wrec1_stage4 conf_wrec1_3) 8)


;; CONF 4 PER WREC1
(= (confgreentime wrec1_stage1 conf_wrec1_4) 45)
(= (confgreentime wrec1_stage2 conf_wrec1_4) 5)
(= (confgreentime wrec1_stage3 conf_wrec1_4) 13)
(= (confgreentime wrec1_stage4 conf_wrec1_4) 7)


;; CONF 5 PER WREC1
(= (confgreentime wrec1_stage1 conf_wrec1_5) 48)
(= (confgreentime wrec1_stage2 conf_wrec1_5) 4)
(= (confgreentime wrec1_stage3 conf_wrec1_5) 12)
(= (confgreentime wrec1_stage4 conf_wrec1_5) 6)


;; CONF 6 PER WREC1
(= (confgreentime wrec1_stage1 conf_wrec1_6) 48)
(= (confgreentime wrec1_stage2 conf_wrec1_6) 5)
(= (confgreentime wrec1_stage3 conf_wrec1_6) 12)
(= (confgreentime wrec1_stage4 conf_wrec1_6) 5)


;; CONF 1 PER WRFC1
(= (confgreentime wrfc1_stage1 conf_wrfc1_1) 54)
(= (confgreentime wrfc1_stage2 conf_wrfc1_1) 9)
(= (confgreentime wrfc1_stage3 conf_wrfc1_1) 27)


;; CONF 2 PER WRFC1
(= (confgreentime wrfc1_stage1 conf_wrfc1_2) 61)
(= (confgreentime wrfc1_stage2 conf_wrfc1_2) 9)
(= (confgreentime wrfc1_stage3 conf_wrfc1_2) 20)


;; CONF 3 PER WRFC1
(= (confgreentime wrfc1_stage1 conf_wrfc1_3) 43)
(= (confgreentime wrfc1_stage2 conf_wrfc1_3) 9)
(= (confgreentime wrfc1_stage3 conf_wrfc1_3) 38)


;; CONF 4 PER WRFC1
(= (confgreentime wrfc1_stage1 conf_wrfc1_4) 47)
(= (confgreentime wrfc1_stage2 conf_wrfc1_4) 15)
(= (confgreentime wrfc1_stage3 conf_wrfc1_4) 28)


;; CONF 5 PER WRFC1
(= (confgreentime wrfc1_stage1 conf_wrfc1_5) 56)
(= (confgreentime wrfc1_stage2 conf_wrfc1_5) 10)
(= (confgreentime wrfc1_stage3 conf_wrfc1_5) 24)


;; CONF 6 PER WRFC1
(= (confgreentime wrfc1_stage1 conf_wrfc1_6) 53)
(= (confgreentime wrfc1_stage2 conf_wrfc1_6) 9)
(= (confgreentime wrfc1_stage3 conf_wrfc1_6) 28)


(= (turnrate fake outside hsac3_c_wrac1) 0.3555)
(= (turnrate fake outside stand_f_wrac1) 0.2313)
(= (turnrate fake outside firth_d_wrac1) 0.0962)
(= (turnrate fake outside silve_w_wrbc1) 0.0361)
(= (turnrate fake outside somer_v_wrbc1) 0.0815)
(= (turnrate fake outside smith_c_wrcc1) 0.0796)
(= (turnrate fake outside abnor_v_wrdc1) 0.0763)
(= (turnrate fake outside oldwa_c_wrec1) 0.0195)
(= (turnrate fake outside oldwa_d_wrec1) 0.0176)
(= (turnrate fake outside wakef_z_wrfc1) 0.2711)
(= (turnrate fake outside broad_x_wrfc1) 0.1516)
(= (occupancy hsac3_c_wrac1) 21.69)
(= (occupancy wrac1_y_wrbc1) 20.26)
(= (occupancy stand_f_wrac1) 17.61)
(= (occupancy firth_d_wrac1) 7.32)
(= (occupancy wrac1_x_wrbc1) 10.86)
(= (occupancy wrbc1_a_wrac1) 37.94)
(= (occupancy wrbc1_b_wrcc1) 9.95)
(= (occupancy silve_w_wrbc1) 0.39)
(= (occupancy somer_v_wrbc1) 8.1)
(= (occupancy wrbc1_b_wrac1) 2.76)
(= (occupancy wrcc1_z_wrbc1) 20.99)
(= (occupancy wrcc1_x_wrdc1) 40.17)
(= (occupancy smith_c_wrcc1) 7.56)
(= (occupancy wrcc1_w_wrdc1) 0.59)
(= (occupancy wrdc1_a_wrcc1) 26.58)
(= (occupancy wrdc1_b_wrec1) 24.84)
(= (occupancy abnor_v_wrdc1) 12.49)
(= (occupancy wrec1_z_wrdc1) 22.36)
(= (occupancy wrec1_y_wrfc1) 5.69)
(= (occupancy oldwa_c_wrec1) 0.39)
(= (occupancy wrec1_y_wrdc1) 0.61)
(= (occupancy oldwa_d_wrec1) 0.36)
(= (occupancy wakef_z_wrfc1) 15.5)
(= (occupancy wrfc1_a_wrec1) 7.44)
(= (occupancy broad_x_wrfc1) 11.95)
(= (occupancy wrac1_z_hsac1) 0.0)
(= (occupancy wrac1_m_stand) 0.0)
(= (occupancy wrac1_n_firth) 0.0)
(= (occupancy wrbc1_r_silve) 0.0)
(= (occupancy wrbc1_s_somer) 0.0)
(= (occupancy wrdc1_q_abnor) 0.0)
(= (occupancy wrdc1_l_absou) 0.0)
(= (occupancy wrfc1_r_broad) 0.0)
(= (occupancy wrfc1_t_wakef) 0.0)
(= (occupancy outside) 50000.0)


(activeconf wrac1 conf_wrac1_1)
(activeconf wrbc1 conf_wrbc1_1)
(activeconf wrcc1 conf_wrcc1_1)
(activeconf wrdc1 conf_wrdc1_1)
(activeconf wrec1 conf_wrec1_1)
(activeconf wrfc1 conf_wrfc1_1)


(active wrac1_stage2)
(= (greentime wrac1) 13)
(= (intertime wrac1) 0)
(= (greentime wrbc1) 0)
(= (intertime wrbc1) 3)
(inter wrbc1_stage2)
(active wrcc1_stage3)
(= (greentime wrcc1) 4)
(= (intertime wrcc1) 0)
(active wrdc1_stage1)
(= (greentime wrdc1) 11)
(= (intertime wrdc1) 0)
(active wrec1_stage1)
(= (greentime wrec1) 11)
(= (intertime wrec1) 0)
(active wrfc1_stage1)
(= (greentime wrfc1) 20)
(= (intertime wrfc1) 0)
(active fake)
(= (counter abnor_v_wrdc1)  0.0)
(= (counter broad_x_wrfc1)   0.0)
(= (counter firth_d_wrac1)   0.0)
(= (counter hsac3_c_wrac1)   0.0)
(= (counter oldwa_c_wrec1)   0.0)
(= (counter oldwa_d_wrec1)   0.0)
(= (counter silve_w_wrbc1)  0.0)
(= (counter smith_c_wrcc1)  0.0)
(= (counter somer_v_wrbc1)  0.0)
(= (counter stand_f_wrac1)   0.0)
(= (counter wakef_z_wrfc1)   0.0)
(= (counter wrac1_m_stand)   0.0)
(= (counter wrac1_n_firth)  0.0)
(= (counter wrac1_x_wrbc1)   0.0)
(= (counter wrac1_y_wrbc1)   0.0)
(= (counter wrac1_z_hsac1)   0.0)
(= (counter wrbc1_a_wrac1)   0.0)
(= (counter wrbc1_b_wrac1)  0.0)
(= (counter wrbc1_b_wrcc1)   0.0)
(= (counter wrbc1_r_silve)  0.0)
(= (counter wrbc1_s_somer)  0.0)
(= (counter wrcc1_w_wrdc1)  0.0)
(= (counter wrcc1_x_wrdc1)  0.0)
(= (counter wrcc1_z_wrbc1)  0.0)
(= (counter wrdc1_a_wrcc1)  0.0)
(= (counter wrdc1_b_wrec1)  0.0)
(= (counter wrdc1_l_absou)  0.0)
(= (counter wrdc1_q_abnor)  0.0)
(= (counter wrec1_y_wrdc1)   0.0)
(= (counter wrec1_y_wrfc1)   0.0)
(= (counter wrec1_z_wrdc1)  0.0)
(= (counter wrfc1_a_wrec1)   0.0)
(= (counter wrfc1_r_broad)   0.0)
(= (counter wrfc1_t_wakef)   0.0)

(= (interlimit wrac1_stage1 )5)
(= (interlimit wrac1_stage2 )6)
(= (interlimit wrac1_stage3 )5)
(= (interlimit wrac1_stage4 )5)

(= (interlimit wrbc1_stage1 )6)
(= (interlimit wrbc1_stage2 )12)
(= (interlimit wrbc1_stage3 )6)
(= (interlimit wrbc1_stage4 )7)
(= (interlimit wrbc1_stage5 )12)

(= (interlimit wrcc1_stage1 )6)
(= (interlimit wrcc1_stage2 )8)
(= (interlimit wrcc1_stage3 )8)
(= (interlimit wrcc1_stage4 )11)
(= (interlimit wrcc1_stage5 )3)
(= (interlimit wrcc1_stage6 )2)

(= (interlimit wrdc1_stage1 )8)
(= (interlimit wrdc1_stage2 )8)
(= (interlimit wrdc1_stage3 )6)
(= (interlimit wrdc1_stage4 )7)

(= (interlimit wrec1_stage1 )3)
(= (interlimit wrec1_stage2 )7)
(= (interlimit wrec1_stage3 )7)
(= (interlimit wrec1_stage4 )7)

(= (interlimit wrfc1_stage1 )5)
(= (interlimit wrfc1_stage2 )9)
(= (interlimit wrfc1_stage3 )8)

(next wrac1_stage1 wrac1_stage2)
(next wrac1_stage2 wrac1_stage3)
(next wrac1_stage3 wrac1_stage4)
(next wrac1_stage4 wrac1_stage1)

(next wrbc1_stage1 wrbc1_stage2)
(next wrbc1_stage2 wrbc1_stage3)
(next wrbc1_stage3 wrbc1_stage4)
(next wrbc1_stage4 wrbc1_stage5)
(next wrbc1_stage5 wrbc1_stage1)

(next wrcc1_stage1 wrcc1_stage2)
(next wrcc1_stage2 wrcc1_stage3)
(next wrcc1_stage3 wrcc1_stage4)
(next wrcc1_stage4 wrcc1_stage5)
(next wrcc1_stage5 wrcc1_stage6)
(next wrcc1_stage6 wrcc1_stage1)

(next wrdc1_stage1 wrdc1_stage2)
(next wrdc1_stage2 wrdc1_stage3)
(next wrdc1_stage3 wrdc1_stage4)
(next wrdc1_stage4 wrdc1_stage1)

(next wrec1_stage1 wrec1_stage2)
(next wrec1_stage2 wrec1_stage3)
(next wrec1_stage3 wrec1_stage4)
(next wrec1_stage4 wrec1_stage1)

(next wrfc1_stage1 wrfc1_stage2)
(next wrfc1_stage2 wrfc1_stage3)
(next wrfc1_stage3 wrfc1_stage1)

(endcycle wrac1 wrac1_stage4)
(endcycle wrbc1 wrbc1_stage5)
(endcycle wrcc1 wrcc1_stage6)
(endcycle wrdc1 wrdc1_stage4)
(endcycle wrec1 wrec1_stage4)
(endcycle wrfc1 wrfc1_stage3)

(availableconf wrac1 conf_wrac1_1)
(availableconf wrac1 conf_wrac1_2)
(availableconf wrac1 conf_wrac1_3)
(availableconf wrac1 conf_wrac1_4)
(availableconf wrac1 conf_wrac1_5)
(availableconf wrac1 conf_wrac1_6)
(availableconf wrbc1 conf_wrbc1_1)
(availableconf wrbc1 conf_wrbc1_2)
(availableconf wrbc1 conf_wrbc1_3)
(availableconf wrbc1 conf_wrbc1_4)
(availableconf wrbc1 conf_wrbc1_5)
(availableconf wrbc1 conf_wrbc1_6)
(availableconf wrcc1 conf_wrcc1_1)
(availableconf wrcc1 conf_wrcc1_2)
(availableconf wrcc1 conf_wrcc1_3)
(availableconf wrcc1 conf_wrcc1_4)
(availableconf wrcc1 conf_wrcc1_5)
(availableconf wrcc1 conf_wrcc1_6)
(availableconf wrdc1 conf_wrdc1_1)
(availableconf wrdc1 conf_wrdc1_2)
(availableconf wrdc1 conf_wrdc1_3)
(availableconf wrdc1 conf_wrdc1_4)
(availableconf wrdc1 conf_wrdc1_5)
(availableconf wrdc1 conf_wrdc1_6)
(availableconf wrec1 conf_wrec1_1)
(availableconf wrec1 conf_wrec1_2)
(availableconf wrec1 conf_wrec1_3)
(availableconf wrec1 conf_wrec1_4)
(availableconf wrec1 conf_wrec1_5)
(availableconf wrec1 conf_wrec1_6)
(availableconf wrfc1 conf_wrfc1_1)
(availableconf wrfc1 conf_wrfc1_2)
(availableconf wrfc1 conf_wrfc1_3)
(availableconf wrfc1 conf_wrfc1_4)
(availableconf wrfc1 conf_wrfc1_5)
(availableconf wrfc1 conf_wrfc1_6)

(= (countcycle wrac1) 0)
(= (countcycle wrbc1) 0)
(= (countcycle wrcc1) 0)
(= (countcycle wrdc1) 0)
(= (countcycle wrec1) 0)
(= (countcycle wrfc1) 0)

(= (cyclelimit) 4)

)
(:goal 
(and 
     
    (>= (counter wrac1_y_wrbc1) 350)(>= (counter wrbc1_b_wrcc1) 350)(>= (counter wrcc1_x_wrdc1) 350)(>= (counter wrdc1_b_wrec1) 350)(>= (counter wrec1_y_wrfc1) 350)
)
)
)