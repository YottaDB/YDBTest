D9I07002688	;test for warning or not for non-graphic in literal
	;
	Write !,"This is D9I07002688"
	Write !,"a	b","a	b" Write "a	b"
	Xecute ("Write !,""a"_"	b""")
	Quit