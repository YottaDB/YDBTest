destroysoc ;
	; This is to test the (no)destroy parameter for socket
	; it does not actually establish a SOCKET, nor write data (that
	; is tested in the socket test)
	set s="SOCKETDESTROY" ; Note here socket name must be of captical letter to pass vms test
	open s:zlisten=port_":TCP":10:"SOCKET"
	if '$TEST write "TEST-E-OPENERR, could not open socket",! halt
	use s
	use $p
	write "Test 1: Test if the default option is nodestroy",!
	write "Before closing socket: ",!
	do showdev^io(s)
	close s
	write "After closing socket: ",!
	do showdev^io(s)
	write !
	write "Test 2: Test destroy parameter",!
	open s:zlisten=port_":TCP":10:"SOCKET"
	use s
	use $p
	write "Before closing socket",!
	do showdev^io(s)
	write "After closing socket",!
	close s:(DESTROY)
	use $p
	do showdev^io(s)
	write !
	write "Test 3: Test nodestroy parameter",!
	open s:zlisten=port_":TCP":10:"SOCKET"
	use $p
	write "Before closing socket",!
	do showdev^io(s)
	close s:(NODESTROY)
	write "After closing socket",!
	do showdev^io(s)
	open s:zlisten=port_":TCP":10:"SOCKET"
	close s
	quit

