soc	; This is to test the limits of LENGTH and WIDTH
	; it does not actually establish a SOCKET, nor write data (that
	; is tested in the socket test)
	set f="FAIL"
	set p="PASS"
	set $ZTRAP="do error^socket"
	set s="sock"
	open s:zlisten=port_":TCP":10:"SOCKET"
	if '$TEST write "TEST-E-OPENERR, could not open socket",! halt
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
	if "FAIL"=fw write "TEST-E-FAIL, was expecting to fail! width = ",val,!
	else  write "PASS",!
	quit
testl(val,fl) ;
	set fail=fl
	use $PRINCIPAL
	do use^io(s,"length="_val)
	use $PRINCIPAL
	if "FAIL"=fl write "TEST-E-FAIL, was expecting to fail! length = ",val,!
	else  write "PASS",!
	quit
error
	use $PRINCIPAL
	new $ZTRAP
	write "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",!
	write $ZSTATUS,!
	if "FAIL"=fail write "PASS. Was expecting error for",!
	else  write "TEST-E-FAIL, Was not expecting to fail",!
	write "continue...",!
	write "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",!
	zgoto mainlvl
	quit
