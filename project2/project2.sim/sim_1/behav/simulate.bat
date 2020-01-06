@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.4\\bin
call %xv_path%/xsim RF_tb_behav -key {Behavioral:sim_1:Functional:RF_tb} -tclbatch RF_tb.tcl -view C:/Users/ECE/Desktop/SNU430.322/project2/RF_tb_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
