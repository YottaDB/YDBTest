	; process the output of
	;	mupip replic -editinstance    -show
	;	mupip replic -source -jnlpool -show
	; into MUMPS variables. note that this routine needs something else to
	; hand it the output of the mupip command, for instance
	; $MUPIP replic -source -jnlpool -show |& $gtm_exe/mumps -run %XCMD 'do ^replinst write fields("CTL","Journal Seqno"),!'
	; $MUPIP replic -source -jnlpool -show |& $gtm_exe/mumps -run %XCMD 'do ^replinst zwrite fields'
replinst
	set detail=$ZCMDLINE["detail"
	for i=1:1 quit:$zeof  read line(i)  do process^replinst(line(i),.fields,detail)
	quit

	; note that the processing doesn't do anything for dates and hex values because I didn't need it
process(line,replinst,detailed)
	new type,fieldname,fieldvalue,lcn
	if $get(detailed,0)'=0  set $piece(line," ",1,2)="",$extract(line,1,1)=""
	set type=$extract(line,1,3)
	quit:type'?1(1"CTL",1"HDR",1"SRC",1"SLT",1"HST")
	set $extract(line,1,4)=""
	set line=$tr(line,"#","")
	if type?1(1"CTL",1"HDR") set lcn=""
	if type?1(1"SRC",1"SLT",1"HST") set lcn=$tr($piece(line,":",1)," ",""),$piece(line,":",1)="",$extract(line,1,2)=""
	set line=$$^%MPIECE(line,"  ","|")
	if type="SRC"
	if type="SLT"
	if type="HST"
	set fieldname=$piece(line,"|",1)
	set fieldvalue=$$FUNC^%TRIM($piece(line,"|",2,99))
	; Number	- fine as is
	if fieldvalue?1.N
	; Number [0xHEX]- skip HEX component
	if fieldvalue?1.N1" [0x"1.(1N,1"A",1"B",1"C",1"D",1"E",1"F")1"]" set fieldvalue=$piece(fieldvalue," ",1)
	; Date		- TODO convert to $HOROLOG format
	if fieldvalue?1"20"2N1"/"2N1"/"2N1" "2N1":"2N1":"2N
	set:lcn'="" replinst(type,lcn,fieldname)=fieldvalue
	set:lcn="" replinst(type,fieldname)=fieldvalue
	quit
