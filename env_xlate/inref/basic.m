basic	;
	w "mumps.gld : ",^GBL,!
	w "a.gld     : ",^["notthis","a.gld"]GBL,!
	w "a.gld     : ",^["notthis","a"]GBL,!
	w "a.gld     : ",^["notthis","$a"]GBL,!
	w "mumps.gld : ",^["notthis",""]GBL,!
	s x="b.gld"
	w "b.gld     : ",^["notthis",x]GBL,!
	s y="x"
	w "b.gld     : ",^["notthis",@y]GBL,!
	s ^["notthis",@y]GBL(1,2,3)="THIS IS B"
	w "$ORDER(extref):",$O(^["notthis",x]GBL("")),!
	; T in the second argument means return dollar_zdir
	d null
zdir	;
	w "Try $ZDIR",!
	w "$ZGBLDIR = ",$ZGBLDIR,!
	w ^["","T"]GBL,!
	s $ZGBLDIR="a"
	w "$ZGBLDIR = ",$ZGBLDIR,!
	w ^["","T"]GBL,!
kill	w "Try a kill:",!
	k ^["notthis",@y]GBL(1,2,3)
	q

err1	w "This will error: ",^["notthis","$b"]GBL,!
	q
err2	w "This will error: ",^["notthis","badgld"]GBL,!
	q
err3	;X in the second argument is a special signal to the sample env.translate routine
	; to error out with a message
	w "This will error with a message:",^["notthis","X"]GBL,!
	q
err4	;Y in the second argument is a special signal to the sample env.translate routine
	; to error out without a message
	w "This will error without a message:",^["notthis","Y"]GBL,!
	q
err5	;Z in the second argument is a special signal to the sample env.translate routine
	; to error out with bad length
	; arg 1 shows whether it will return with an error or not
	w "This will error with too long a return string (and success):  ",^["success","Z"]GBL,!
err6	w "This will error without too long a return string (and error): ",^["error ","Z"]GBL,!
	q
null	; try null strings
	w "Try empty strings (should default to $ZGBLDIR",!
	w "$ZGBLDIR = ",$ZGBLDIR,!
	w ^["",""]GBL,!
	s $ZGBLDIR="a"
	w "$ZGBLDIR = ",$ZGBLDIR,!
	w ^["",""]GBL,!
	q
