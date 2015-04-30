@echo off
cd bin
start love "../marin0se" -debug server
ping -n 2 127.0.0.1>nul
start love "../marin0se" -debug client
exit