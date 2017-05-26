misc	; test quit if for xecute use open close with long names
	write "test quit if for xecute use open close with long names",!
	set seperator="##################################################"
	write seperator,!
testquit ;
	write "Test QUIT",!
	set lclquit=$$lclquit
	do ^examine(lclquit,"long local variable","testing QUIT at "_$ZPOSITION)
	set gblquit=$$gblquit
	do ^examine(gblquit,"long global variable","testing QUIT at "_$ZPOSITION)
	set indrquit=$$indrquit
	do ^examine(indrquit,"long local variable","testing QUIT at "_$ZPOSITION)
	set nakedquit=$$nakedquit
	do ^examine(nakedquit,"value 1,2","testing QUIT at "_$ZPOSITION)
testif	;
	write seperator,!
	write "Test IF",!
	set thisisthelonglocalvariablefortrue=1
	set thisisthelonglocalvariableforfalse=0
	set ^thisistheglobalvariableforiftrue=1
	set ^thisistheglobalvariableforiffalse=0
	if thisisthelonglocalvariablefortrue write "local true",!
	else  write "TEST-E-ERROR",!
	if 'thisisthelonglocalvariableforfalse write "local false",!
	else  write "TEST-E-ERROR",!
	if ^thisistheglobalvariableforiftrue write "global true",!
	else  write "TEST-E-ERROR",!
	if '^thisistheglobalvariableforiffalse write "global false",!
	else  write "TEST-E-ERROR",!
	set ^thisistheglobalvariableforiffalse(1,2)=0
	set ^thisistheglobaldummy(1,2)=1
	set ^thisistheglobalvariableforiffalse(1,1)=1
	if '^(2) write "global false",!
	else  write "TEST-E-ERROR",!
testfor	; for loop
	write seperator,!
	write "Test FOR",!
	new thisisthelonglocalvariablefor
	for thisisthelonglocalvariablefor=1:1:5 do
	. write "thisisthelonglocalvariablefor=",thisisthelonglocalvariablefor,!
execute	; xecute
	write seperator,!
	write "Test XECUTE",!
	set thisisthelonglocalvariableforxecute="write ""xecute thisisthelonglocalvariableforxecute"",!"
	xecute thisisthelonglocalvariableforxecute
	set ^thisisthelongglobalvariableforxecute="write ""xecute ^thisisthelongglobalvariableforxecute"",!"
	xecute ^thisisthelongglobalvariableforxecute
	set ^thisisthelongglobalvariableforxecute(1,"naked")="set nakedxecute=""xecuted"""
	set ^thisisthelongglobalvariabledummy(1,"naked")="set nakedxecute=""wrong"""
	set ^thisisthelongglobalvariableforxecute(1,"naked2")="dummy"
	xecute ^("naked")
	do ^examine($GET(nakedxecute),"xecuted","testing XECUTE at "_$ZPOSITION)

files	; use/open/close
	; tested in io/inref/io.m
	quit
	; [XXX] longquitlcl()	; quit long local variable
lclquit()
	set thisisthelonglocalvariableforquit="long local variable"
	set thisisthelonglocalvariable="this one should not be used"
	quit thisisthelonglocalvariableforquit
	; [XXX] longquitgbl()	; quit long global variable
gblquit()
	set ^thisislongglobalvariableforquit="long global variable"
	set ^thisislongglobalvariable="this one should not be used"
	quit ^thisislongglobalvariableforquit
nakedquit()
	set ^thisislongglobalvariableforquit(1,2)="value 1,2"
	set ^thisislongdummyvar(1,2)="this is dummy var"
	set ^thisislongglobalvariableforquit(1,1)="value 1,1"
	quit ^(2)
indrquit()
	set indirectvariableforquit="thisisthelonglocalvariableforquit"
	quit @indirectvariableforquit
