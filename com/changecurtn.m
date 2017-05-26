chagecurtn	;
	write "$ZROUTINES=",$ZROUTINES,!
	set unix=$ZVersion'["VMS"
	if unix set cshcom="csh"
	else  set cshcom="com"
	set exponent=$ZTRNLNM("gtm_test_dbcreate_initial_tn")
	set inittn=2**exponent	; this is not going to be very accurate for very large numbers, but it's ok
	set infile="reg_list.txt"
	set helper1="chcurtn_c."_cshcom	;change
	set helper2="chcurtn_d."_cshcom	; dump /fileheader
	open infile:(READONLY)
	open helper1:(NEWVERSION)
	open helper2:(NEWVERSION)
	use helper1
	if unix  do
	. write "date",!
	. write "echo ""Random transaction number set for the database (current_tn) is ",inittn," (0x",$$FUNC^%DH(inittn),")""",!
	. write "$DSE << EOF",!
	else  do
	. write "$ write sys$output f$cvtime()",!
	. write "$ write sys$output ""Random transaction number set for the database (current_tn) is ",inittn," (0x",$$FUNC^%DH(inittn),")""",!
	. write "$ DSE",!
	use helper2
	if unix  do
	. write "date",!
	. write "$DSE << EOF",!
	else  do
	. write "$ write sys$output f$cvtime()",!
	. write "$ DSE",!
	use infile
	for i=1:1 use infile read line set zeof=$ZEOF use $PRINCIPAL quit:zeof  do:line'=""
	. use helper1
	. if unix  do
	.. write "find -reg=",line,!
	.. write "change -fileheader -current_tn=",$$FUNC^%DH(inittn),!
	. else  do
	.. write "find /reg=",line,!
	.. write "change /fileheader /current_tn=",$$FUNC^%DH(inittn),!
	. use helper2
	. if unix  do
	..  write "find -reg=",line,!
	..  write "dump -fileheader",!
	. else  do
	..  write "find /reg=",line,!
	..  write "dump /fileheader",!
	use helper1
	write "quit",!
	if unix write "EOF",!
	use helper2
	write "quit",!
	if unix write "EOF",!
	close helper1
	close helper2
	close infile
	quit
