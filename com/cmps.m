	; cmp -s replacement for AIX
cmps(file1,file2)	;
	new ret,zeof,lines,line1,line2
	set (ret,zeof,lines)=0
	open file1:(read:chset="M")
	open file2:(read:chset="M")
	use file1
	for  quit:(zeof!ret)  do
	. use file1 read line1 set zeof=zeof+$zeof
	. use file2 read line2 set zeof=zeof+$zeof
	. set lines=lines+1
	. if line1'=line2 set ret=1 quit
	close file1
	close file2
	quit ret
