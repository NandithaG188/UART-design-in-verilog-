transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/SUJATHA/Downloads/t2a_uart/t2a_uart/uart_rx/code {C:/Users/SUJATHA/Downloads/t2a_uart/t2a_uart/uart_rx/code/uart_rx.v}

vlog -vlog01compat -work work +incdir+C:/Users/SUJATHA/Downloads/t2a_uart/t2a_uart/uart_rx/.test {C:/Users/SUJATHA/Downloads/t2a_uart/t2a_uart/uart_rx/.test/tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb

add wave *
view structure
view signals
run -all
