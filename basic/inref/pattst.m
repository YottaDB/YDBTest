pattst	; Test of MUMPS pattern match operator

	New
	Do begin^header($TEXT(+0))

	Set errstep=errcnt
	Write "Test of MUMPS pattern match operator",!
	Set ITEM="pattern match "
	Do init
	For p="1U","3N","2P","4L","1""1234""","3N1""H""","1.3N1P.2N",".E.N" Do match(p)
	If errstep=errcnt Write "a  PASS",!

	Set errstep=errcnt
	For p="1.AN1""HE""1P.N","1.AN1.3""HE"".3N","3N.1""H""",".1""1234""" Do match(p)
	If errstep=errcnt Write "b  PASS",!

	Set errstep=errcnt
        For p=".1""123""",".1""123"".N",".N1""HE"".P2N1A" Do match(p)
	If errstep=errcnt Write "c  PASS",!

; Test for PER 002579:
	Set errstep=errcnt
	Set X="1234X5678"
	Xecute "Write X?.N1U.1N"		; This failed with an ACCVIO.
	If errstep=errcnt Write "  PASS - PER 002579",!

	Do end^header($TEXT(+0))
	Quit

match(P)
	New x,k
	For k=1:1:10 Set x=$PIECE(X,"|",k)  Do ^examine(x?@P,$PIECE(R(P)," ",k),ITEM_x_"?"_P)
	Quit

init
	Set X="L|873|*A|1,12|123HE.123|123HE|123H,&ADE|123|1234|12345HE.00K"
	Set R("1U")="1 0 0 0 0 0 0 0 0 0"
	Set R("3N")="0 1 0 0 0 0 0 1 0 0"
	Set R("2P")="0 0 0 0 0 0 0 0 0 0"
	Set R("4L")="0 0 0 0 0 0 0 0 0 0"
	Set R("1""1234""")="0 0 0 0 0 0 0 0 1 0"
	Set R("3N1""H""")="0 0 0 0 0 0 0 0 0 0"
	Set R("1.3N1P.2N")="0 0 0 1 0 0 0 0 0 0"
	Set R(".E.N")="1 1 1 1 1 1 1 1 1 1"
	Set R("1.AN1""HE""1P.N")="0 0 0 0 1 0 0 0 0 0"
	Set R("1.AN1.3""HE"".3N")="0 0 0 0 0 1 0 0 0 0"
	Set R("3N.1""H""")="0 1 0 0 0 0 0 1 0 0"
	Set R(".1""1234""")="0 0 0 0 0 0 0 0 1 0"
	Set R(".1""123""")="0 0 0 0 0 0 0 1 0 0"
	Set R(".1""123"".N")="0 1 0 0 0 0 0 1 1 0"
	Set R(".N1""HE"".P2N1A")="0 0 0 0 0 0 0 0 0 1"
	Quit
