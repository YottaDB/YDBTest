setpiece	; Test of Set command with the $PIECE function
	New
	Do begin^header($TEXT(+0))

	Set st="FOFOFOFO"
	Set $PIECE(st,"F",2,3)="HELP"
	Do ^examine(st,"FHELPFOFO","$PIECE(st,""F"",2,3)")

	Set st="ABCABCABCABC"
	Set $PIECE(st,"BC",2,3)="HELP"
	Do ^examine(st,"ABCHELPBCABC","$PIECE(st,""BC"",2,3)")

	Set st=""
	Set $PIECE(st,"ABC",1,2)="HELP"
	Do ^examine(st,"HELP","$PIECE(st,""ABC"",1,2)")

	Set st="QUIET_FOOL"
	Set $PIECE(st,"_",2,3)="HELP"
	Do ^examine(st,"QUIET_HELP","$PIECE(st,""_"",2,3)")

	Set st="Q_I_Y_Z_D_E_F_G"
	Set $PIECE(st,"_",3,9)="HELP"
	Do ^examine(st,"Q_I_HELP","$PIECE(st,""_"",3,9)")

	Set st="DSDFSDFSA"
	Set $PIECE(st,"D",4,3)="HELP"
	Do ^examine(st,"DSDFSDFSA","$PIECE(st,""D"",4,3)")

	Set st="ASDASDASD"
	Set $PIECE(st,"D",4,5)="HELP"
	Do ^examine(st,"ASDASDASDHELP","$PIECE(st,""D"",4,5)")

	Set st=""
	Set $PIECE(st,"-",20)=""
	Do ^examine(st,"-------------------","$PIECE(st,""-"",20)")

	New $ZTRAP
	Set $ZTRAP="Set $ZTRAP=""""  Goto trap"
	Set $PIECE(st,"-",1048580)="HELP"
	Set errcnt=errcnt+1
	Write "** FAIL - $ZTRAP should have bypassed this on a %GTM-E-MAXSTRLEN error",!
	Goto end

trap	Do ^examine($PIECE($ZSTATUS,",",3),"%GTM-E-MAXSTRLEN","$ZTRAP")

end	If errcnt=0 Write "   PASS",!
	Do end^header($TEXT(+0))
	Quit
