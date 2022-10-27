if {[file exists "./work.dat"] == 0} {
    vlib ./work
}

vlog ./testfixture.v ../1/arctan.v
vsim work.testfixture

add wave -position insertpoint  \
sim:/testfixture/rst \
sim:/testfixture/i   \
sim:/testfixture/inx \
sim:/testfixture/iny \
sim:/testfixture/out \
sim:/testfixture/ans \
sim:/testfixture/pass \
sim:/testfixture/err

run -all
