recterm
t1
	set $etrap="write $zstatus,! halt"
	for i=1:1 do
	.	tstart ():SERIAL
  	.	set ^a(i)=$j(" ",250)
	.	if $trestart<3 trestart
	.	tcommit
	quit
t2
	set $etrap="do err^recterm"
    	for i=1:1:856  set ^a(i)=$j(i,100)
    	quit
err	; ignore the GBLOFLOW error and halt
       hang 10 ; Adequate time to flush buffers
       halt
