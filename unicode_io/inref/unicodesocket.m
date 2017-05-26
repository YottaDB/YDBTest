unicodesocket;
	; This is to test the limits of LENGTH and WIDTH
	; it does not actually establish a SOCKET, nor write data (that
	; is tested in the socket test)
	set f="FAIL"
	set p="PASS"
	SET $ZTRAP="GOTO errorAndCont^errorAndCont"
	set s="sock"
	open s:zlisten=port_":TCP":10:"SOCKET"
	if '$TEST write "TEST-E-OPENERR, could not open unicodesocket",! halt
	do test(-10,f,f)
	do test(0,p,p)
	do test(32767,p,p)
	do test(32768,p,p)
	do test(1048576,p,p)
	do test(1048577,p,p)
	close s
	quit
test(val,fw,fl) ;
	use $PRINCIPAL
	set mainlvl=$ZLEVEL
	write "----------------------",!,"TEST val = ",val,!
	do testw(val,fw)
	do testl(val,fl)
	quit
testw(val,fw) ;
	set fail=fw
	use $PRINCIPAL
	do use^io(s,"width="_val)
	use $PRINCIPAL
	if "FAIL"=fw write "Was expecting to fail! width = ",val,!
	else  write "PASS",!
	quit
testl(val,fl) ;
	set fail=fl
	use $PRINCIPAL
	do use^io(s,"length="_val)
	use $PRINCIPAL
	if "FAIL"=fl write "Was expecting to fail! length = ",val,!
	else  write "PASS",!
	quit
