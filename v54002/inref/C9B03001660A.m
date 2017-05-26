C9B03001660A   ; ; ; look for problems subscripted FOR control variables
        ;
	for i=1:1:1000 set a1001=$char(i#26+65)_i,@a1001=i
	quit
	