@echo off
set /p Input=Enter path to dir: 

iverilog -g2005-sv %Input%\*.sv
vvp a.out > log.txt
del a.out