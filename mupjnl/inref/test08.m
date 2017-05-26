test08;
	S unix=$zv'["VMS"
  	F i=1:1:10 DO
  	. if (i=2)&(unix) do
	.. zsy "$DSE all -buff"
	.. h 2
	.. zsy "$gtm_tst/com/abs_time.csh time1.txt"
	.. h 2
	. if (i=2)&'unix do
	.. zsy "DSE all /buff"
	.. h 2
	.. zsy "pipe write sys$output f$time() > time1.txt"
	.. h 2
	. s tflag=0
	. if i#2 set tflag=1
  	. if tflag=1 ZTS  
	. else  TS
  	. S ^a(i)="A"_i
  	. S ^b(i)="B"_i
  	. S ^c(i)="C"_i
  	. S ^d(i)="D"_i
  	. if tflag=1 ZTC  
	. else  TC
 	Q
