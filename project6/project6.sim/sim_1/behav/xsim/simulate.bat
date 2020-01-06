@echo off
REM ****************************************************************************
REM Vivado (TM) v2018.3 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Sat Jun 01 17:06:07 +0900 2019
REM SW Build 2405991 on Thu Dec  6 23:38:27 MST 2018
REM
REM Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
call xsim cpu_TB_behav -key {Behavioral:sim_1:Functional:cpu_TB} -tclbatch cpu_TB.tcl -view C:/Users/Yeom/projects/SNU430.322/project6/cpu_TB_behav.wcfg -view C:/Users/Yeom/projects/SNU430.322/project6/cpu_TB_behav1_pipeline_reg.wcfg -view C:/Users/Yeom/projects/SNU430.322/project6/cpu_TB_behav1_stage view.wcfg -view C:/Users/Yeom/projects/SNU430.322/project6/cpu_TB_behav_datafwd_debug.wcfg -view C:/Users/Yeom/projects/SNU430.322/project6/cpu_TB_behav1_jrl float.wcfg -view C:/Users/Yeom/projects/SNU430.322/project6/branch_predictor_dev.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
