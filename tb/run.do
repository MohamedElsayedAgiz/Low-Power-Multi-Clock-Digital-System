vlib work
vlog ../rtl/*/*.*v
vlog ../rtl/UART/Top/*.*v
vsim -voptargs=+acc work.tb_SYS_TOP
do wave.do
run -all