mlabelsnumber;	;
	write !,$t(+0)," test Started",!,!
	;
	set fnbase="GTMLabelNumericTest"
	set fn=fnbase_".m"
	open fn:(NewVersion)
	use fn
	;
	set max=5
	set labname(1)="12345678901234567890123456789012345"
	set labname(2)="12345678"
	set labname(3)="1234567890123456789012345678901"
	set labname(4)="%123456789012345678901234567890"
	set labname(5)="%1234567890A234567890B234567890"
	;
	if $zv["VMS" set ufnbase=$$FUNC^%UCASE(fnbase)
	else  set ufnbase=fnbase
	set zposexpected(1)=labname(3)_"+3^"_ufnbase	; For truncation to 31 char
	for testno=2:1:max do
	. write labname(testno),";       ",!
	. write "       write ""I am in "_labname(testno),"""",",!",!
	. write "       set tstno=testno",!
	. write "       set zposresult(tstno)=$zpos",!
	. write "       quit",!
	. set zposexpected(testno)=labname(testno)_"+3^"_ufnbase
	;
	close fn
	use $PRINCIPAL
	;
	for testno=1:1:max do
	. set prg=labname(testno)_"^"_fnbase
	. write "do ",prg,!
	. do @prg
	;
	set mlaberrno=0
	do verify(.zposresult,.zposexpected)
	if mlaberrno=0 write !,$t(+0)," test Passed with numeric labels",!,!
	quit
verify(result,expected)
	for i=1:1:testno do
	. if $get(result(i))'=expected(i) write "Verify Failed: index ",i," Expected ",expected(i)," Found ",$get(result(i)),!  set mlaberrno=mlaberrno+1
	quit
