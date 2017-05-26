trterr	;
	; Make sure that error is associated with line of code it occurs in
	; rather than the last line of the module

	Write "trterr starting",!
	New (act)
	If '$Data(act) New act Set act="W !,$ZPOS,!"
	New $ETrap
	Set $ETrap="W !,$ZS,!,$EC,! S $EC="""" ZG "_$ZLevel_":exit" 
	Set cnt=0
	Do pass	;2
	Do flob ;3
	Do fail^trterr(1)	;4
	Do pass^trterr(1,2,3,4) ;5
	Set x=$$flob ;6
	Set cnt=cnt+1 Xecute act
exit	;Write !,$Select(cnt:"FAIL",1:"PASS")," from ",$Text(+0)
	Quit
pass(a,b,c)
	Quit
	QUIT
	Halt
	quit
	halt
fail	
	Quit
