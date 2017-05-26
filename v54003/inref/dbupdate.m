dbupdate ;
    for i=0:1:20 hang 1 do  for j=0:1:500 tstart ():(serial:transaction="BATCH") set ^a(i,j)=j tcommit
    for i=0:1:20 hang 1 do  for j=0:1:500 tstart ():(serial:transaction="BATCH") set ^b(i,j)=j tcommit
    hang 5
    set ^a(16,20001)=20001
    set ^b(16,20001)=20001
    quit
