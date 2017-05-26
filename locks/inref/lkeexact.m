cleartest ;
	d setzsycmds
	;
	w "Step 1: Verify lke clear -all",!
	w "Setting locks",!	
	d setlocks	
	w "Issue: "_clearall,!
	zsy clearall	
	w !
	;
	w "Step 2: Verify lke clear -lock=^X",!
	w "Setting locks",!	
	d setlocks
	w "Issue: "_clearx,!
	zsy clearx
	w !
	;
	w "Step 3: Verify lke clear -lock=^X -exact",!
	w "Setting locks",!	
	d setlocks
	w "Issue: "_clearxexact,!
	zsy clearxexact
	w !
	;
	w "Step 4: Verify lke clear -lock=^YYYY",!
	w "Setting locks",!	
	d setlocks
	w "Issue: "_clearyyyy,!
	zsy clearyyyy
	w !
	;
	w "Step 5: Verify lke clear -lock=^YYYY -exact",!
	w "Setting locks",!	
	d setlocks
	w "Issue: "_clearyyyyexact,!
	zsy clearyyyyexact
	w !
	;
	w "Step 6: Verify lke clear -lock=^X(""cat"",""hat"")",!
	w "Setting locks",!	
	d setlocks
	w "Issue: "_clearcathatsub,!
	zsy clearcathatsub
	w !
	;
	w "Step 7: Verify lke clear -lock=^X(""cat"",""hat"") -exact",!
	w "Setting locks",!	
	d setlocks
	w "Issue: "_clearcathatsubexact,!
	zsy clearcathatsubexact
	w !
	;	
	w "Step 8: Verify lke clear -lock=^X(""w"",""x"",""y"")",!
	w "Setting locks",!	
	d setlocks
	w "Issue: "_clearwxysub,!
	zsy clearwxysub
	w !
	;
	w "Step 9: Verify lke clear -lock=^X(""w"",""x"",""y"") -exact",!
	w "Setting locks",!	
	d setlocks
	w "Issue: "_clearwxysubexact,!
	zsy clearwxysubexact
	w !
	;	
	w "Step 10: Verify clear -exact on non-existent lock",!
	w "Issue: "_clearexactlockdoesnotexist,!
	w "Should see no lock message",!
	zsy clearexactlockdoesnotexist
	w !
	;
	w "Step 11: Verify lke show -exact",!
	w "Issue: "_showexact,!
	w "Should see qualifier error",!
	zsy showexact
	w !
	;	
	w "Step 12: Verify lke clear -exact",!
	w "Issue: "_clearexactnolockqual,!
	w "Should see qualifier error",!
	zsy clearexactnolockqual
	w !
	;	
	q
	
setlocks ; note: first set clears existing locks
	l ^X
	l +^X1
	l +^X2
	l +^X3
	l +^X4
	l +^X5
	l +^X6
	l +^X(1)
	l +^X(1,1)
	l +^X(1,1,1)
	l +^X(1,1,1,1)
	l +^X("cat")
	l +^X("cat","hat")
	l +^X("cat","hat","rat")
	l +^X("w")
	l +^X("w","x")
	l +^X("w","x","y")
	l +^X("w","x","y","z")
	l +^X(1,"train","plain")
	l +^Y
	l +^YY
	l +^YYY
	l +^YYYY
	l +^YYYYY
	l +^YYYYYY
	l +^YYYYYYY
	q

setzsycmds ; note: ('s are backslashed in Unix to prevent "help" from the shell
	set unix=$zv'["VMS"
	if unix do
	. s clearall="$LKE clear -all -noi"
	. s clearx="$LKE clear -lock=^X -noi"
	. s clearxexact="$LKE clear -lock=^X -exact -noi"
	. s clearyyyy="$LKE clear -lock=^YYYY -noi"
	. s clearyyyyexact="$LKE clear -lock=^YYYY -exact -noi"
	. s clearcathatsub="$LKE clear -lock=^X\(""cat"",""hat""\) -noi"
	. s clearcathatsubexact="$LKE clear -lock=^X\(""cat"",""hat""\) -exact -noi"
	. s clearwxysub="$LKE clear -lock=^X\(""w"",""x"",""y""\) -noi"
	. s clearwxysubexact="$LKE clear -lock=^X\(""w"",""x"",""y""\) -exact -noi"
	. s showexact="$LKE show -exact"
	. s clearexactnolockqual="$LKE clear -exact"
	. s clearexactlockdoesnotexist="$LKE clear -lock=^DOESNOTEXIST -exact"
	else  do
	. s clearall="$LKE clear /all /noi"
	. s clearx="$LKE clear /lock=^X /noi"
	. s clearxexact="$LKE clear /lock=^X /exact /noi"
	. s clearyyyy="$LKE clear /lock=^YYYY /noi"
	. s clearyyyyexact="$LKE clear /lock=^YYYY /exact /noi"
	. s clearcathatsub="$LKE clear /lock=""^X(""""cat"""",""""hat"""")"" /noi"
	. s clearcathatsubexact="$LKE clear /lock=""^X(""""cat"""",""""hat"""")"" /exact /noi"
	. s clearwxysub="$LKE clear /lock=""^X(""""w"""",""""x"""",""""y"""")"" /noi"
	. s clearwxysubexact="$LKE clear /lock=""^X(""""w"""",""""x"""",""""y"""")"" /exact /noi"
	. s showexact="$LKE show /exact"
	. s clearexactnolockqual="$LKE clear /exact"
	. s clearexactlockdoesnotexist="$LKE clear /lock=^DOESNOTEXIST /exact"
	q	
