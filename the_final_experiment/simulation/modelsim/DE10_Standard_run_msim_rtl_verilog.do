transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/program_learning/verilog/My_design/the_final_experiment/Code {D:/program_learning/verilog/My_design/the_final_experiment/Code/ldw_ALU.v}
vlog -vlog01compat -work work +incdir+D:/program_learning/verilog/My_design/the_final_experiment/Code {D:/program_learning/verilog/My_design/the_final_experiment/Code/ldw_RegFile.v}
vlog -vlog01compat -work work +incdir+D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/IF {D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/IF/ldw_PC.v}
vlog -vlog01compat -work work +incdir+D:/program_learning/verilog/My_design/the_final_experiment/Code/General {D:/program_learning/verilog/My_design/the_final_experiment/Code/General/dffe32.v}
vlog -vlog01compat -work work +incdir+D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/IF {D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/IF/ldw_IF.v}
vlog -vlog01compat -work work +incdir+D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/ID {D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/ID/ldw_IR.v}
vlog -vlog01compat -work work +incdir+D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/ID {D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/ID/ldw_ID.v}
vlog -vlog01compat -work work +incdir+D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/ID {D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/ID/ldw_CU.v}
vlog -vlog01compat -work work +incdir+D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/EXE {D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/EXE/ldw_DEReg.v}
vlog -vlog01compat -work work +incdir+D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/EXE {D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/EXE/ldw_EXE.v}
vlog -vlog01compat -work work +incdir+D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/MEM {D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/MEM/ldw_EMReg.v}
vlog -vlog01compat -work work +incdir+D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/IF {D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/IF/ldw_IMem.v}
vlog -vlog01compat -work work +incdir+D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/WB {D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/WB/ldw_MWReg.v}
vlog -vlog01compat -work work +incdir+D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU {D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/ldw_CPU.v}
vlog -vlog01compat -work work +incdir+D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/MEM {D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/MEM/ldw_MEM.v}
vlog -vlog01compat -work work +incdir+D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/WB {D:/program_learning/verilog/My_design/the_final_experiment/Code/CPU/WB/ldw_WB.v}
vlog -vlog01compat -work work +incdir+D:/program_learning/verilog/My_design/the_final_experiment/Code/General {D:/program_learning/verilog/My_design/the_final_experiment/Code/General/IMem.v}
vlog -vlog01compat -work work +incdir+D:/program_learning/verilog/My_design/the_final_experiment/Code/General {D:/program_learning/verilog/My_design/the_final_experiment/Code/General/Mem.v}

vlog -vlog01compat -work work +incdir+D:/program_learning/verilog/My_design/the_final_experiment/simulation/modelsim {D:/program_learning/verilog/My_design/the_final_experiment/simulation/modelsim/ldw_CPU.vt}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  ldw_CPU_vlg_tst

add wave *
view structure
view signals
run -all
