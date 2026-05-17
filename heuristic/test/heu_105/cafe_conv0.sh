#!/bin/bash

declare cafe="./result/result_cafe_dot.csv"
declare tmp="./result/tmp_cafe.csv"
declare prefix="./heu_105/result/Instancesv2_round/"
fst_line="Encoding,Horizon,Problem,counter wrac1_y_wrbc1,counter wrbc1_b_wrcc1,counter wrcc1_x_wrdc1,counter wrdc1_b_wrec1,counter wrec1_y_wrfc1,Total"

mv "${cafe}" "${tmp}"
echo "${fst_line}" >> "${cafe}"
tail -n +2 "${tmp}" | 
while IFS=',' read -r enc HOR PROBLEM l1 l2 l3 l4 l5 TOT; do
      echo "${enc},${HOR},${prefix}${PROBLEM},${l1},${l2},${l3},${l4},${l5},${TOT}" >> "${cafe}"
done