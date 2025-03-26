@echo off
iverilog -g2005-sv .\*.sv
vvp a.out > log.txt
del a.out