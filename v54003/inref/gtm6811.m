dohang
  set ^stop=0
  open "running.txt" ; create file to indicate that the process is running
  for i=1:1:120 halt:^stop  hang 1
  write "%GTM-E-TIMEOUT, Process not stopped in allotted time",!
  halt

dohang1
  set ^a=1
  goto dohang

dohang2
  set ^a=2
  goto dohang

dowrite
  write ^a,!
  halt

dostop
  set ^stop=1
  halt
