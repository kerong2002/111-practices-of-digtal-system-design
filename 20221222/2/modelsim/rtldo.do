vlog ./hw.v ./tb.v 
vsim work.tb

add wave -position insertpoint  \
sim:/tb/U1/answer \
sim:/tb/U1/cal_Lshift \
sim:/tb/U1/cal_Rshift \
sim:/tb/U1/cal_add \
sim:/tb/U1/cal_mul \
sim:/tb/U1/cal_sub \
sim:/tb/U1/clk \
sim:/tb/U1/cmd \
sim:/tb/U1/req \
sim:/tb/U1/cstate \
sim:/tb/U1/en \
sim:/tb/U1/nstate \
sim:/tb/U1/num \
sim:/tb/U1/rst \
sim:/tb/U1/stack \
sim:/tb/U1/top1 \
sim:/tb/U1/top2 \
sim:/tb/U1/valid \
sim:/tb/U1/variable

run -all
