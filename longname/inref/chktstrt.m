chktstrt(flagval) ;
	; the routine is intended to check two things.
	; i)  longnamed  variable values (both normal & indirection) when passed as parameters to tstart gets preserved properly.
	; ii) check for view "noundef" condition, to ensure no error is thrown when an undefined variable is accessed.
	set ^globalcounter=0
	set alongname="aindirlongnamecheck"
	set bisalsoaverylongname="sometext"
	set ccouldbe="%cindirl" ;this set is to ensure no 8char truncation happens
	set %cindirl="I"
	set ccouldbeveryverylongtoo="%cindirlongnamecheck"
	set %cindirlongnamecheck="new"
	set disthelongestofalltocount="d2345678"
	set eiam8bit="e0000000"
	set avariableisalongvariable="aindirlongnamecheck"
	set aindirlongnamecheck="org"
	set someothervariable="."

	set dorestart=2
	; the below line is commented because of an Issue in tstart where more than 4 local variables cannot be restored on VMS.CR is C9E11-002656
	; pls uncomment & run the test when CR is fixed
	;tstart (alongname,bisalsoaverylongname,@ccouldbeveryverylongtoo,%cindirl,disthelongestofalltocount,@avariableisalongvariable):(serial:transaction="BA")
	tstart (bisalsoaverylongname,@ccouldbeveryverylongtoo,%cindirl,@avariableisalongvariable):(serial:transaction="BA")
	write "--------------------------------------------",!
	write "$trest = ",$trestart,!
	write "inside TP zwr=",!  zwr
	set ^globalcounter=^globalcounter+1
	set alongname=alongname+1
	set bisalsoaverylongname=bisalsoaverylongname_" somemoretext"
	set @ccouldbe=$get(%cindirl)_" intent to check 8 char"
	set @ccouldbeveryverylongtoo=$get(@ccouldbeveryverylongtoo)_$trestart
	set disthelongestofalltocount=disthelongestofalltocount-1
	set eiam8bit=eiam8bit_^globalcounter
	set avariableisalongvariable="someothervariable"
	set aindirlongnamecheck=$get(aindirlongnamecheck)_"_1"_^globalcounter
	set @avariableisalongvariable=$get(avariableisalongvariable)_"_2"_^globalcounter
	set someothervariable=$get(someothervariable)_"_3"_^globalcounter
	write "--------------",!
	write "inside TP, after sets, zwrite=",! zwrite
	write "--------------------------------------------",!
	write "check for ""noundef"" inside tstart",!,!
        if ("errorOFF"=flagval) do
        . set iamalongvarverylongoflengthup31=iamalongvarverylongoflength29+10
        . write "iamalongvarverylongoflength29 variable is accessed without defining but I am in a ""view noundef"" state",!
	set dorestart=dorestart-1
	if -1<dorestart trestart
	trollback
	write "--------------------------------------------",!
	; examine test routine is used here to match the expected values with the calculated values after tstart section
	write "outside TP zwr=",!  zwr
	;do ^examine($get(alongname),"1"," alongname") ;line commented for CR C9E11-002656
	do ^examine($get(alongname),"3"," alongname")
	do ^examine($get(aindirlongnamecheck),"org_11"," aindirlongnamecheck")
	do ^examine($get(avariableisalongvariable),"someothervariable"," avariableisalongvariable")
	do ^examine($get(bisalsoaverylongname),"sometext somemoretext"," bisalsoaverylongname")
	do ^examine($get(ccouldbeveryverylongtoo),"%cindirlongnamecheck"," ccouldbeveryverylongtoo")
	do ^examine($get(@ccouldbeveryverylongtoo),"new2"," ccouldbeveryverylongtoo")
	do ^examine($get(%cindirl),"I intent to check 8 char"," %cindirl")
	;do ^examine($get(disthelongestofalltocount),"-1"," disthelongestofalltocount") ;line commented for CR C9E11-002656
	do ^examine($get(disthelongestofalltocount),"-3"," disthelongestofalltocount")
	do ^examine($get(eiam8bit),"e0000000111"," eiam8bit")
	do ^examine($get(someothervariable),"someothervariable_21_31"," someothervariable")
	quit
