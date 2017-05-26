viewundef ; test VIEW "[NO]UNDEF"
	set lcl=1
	set gbl=2
	set pc=3 ; test % as well
	set maxlen=31
	set $ZTRAP="set line=$ZPOSITION goto ERROR"
	view "UNDEF"
	set exp="error"
	do test
	write "will now test VIEW ""NOUNDEF""",!
	view "NOUNDEF"
	set exp="success"
	do test
	quit
test	w "In test...",!
	set counter=0
	for i=1:1 quit:counter=-1  do check(lcl)
	set counter=0
	for i=1:1 quit:counter=-1  do check(gbl)
	quit
check(glv) ;
	;write "-------",!
	;counter shows what we're testing
	;[001-031] no %, no subs, length [1-31]
	;[101-131]    %, no subs, length [1-31]
	;[201-231] no %,    subs, length [1-31]
	;[301-331]    %,    subs, length [1-31]
	;[400] end
	if (lcl=glv) set uparrow=""
	if (gbl=glv) set uparrow="^"
	set counter=counter+1
	set len=counter#100
	if len=(maxlen+1) set counter=counter+100-len+1,len=1
	if 400<counter set counter=-1 quit
	set subspc=counter\100
	set pc=subspc#2
	set subs=0
	if (subspc-pc) set subs=1
	set var=""
	if len>1  do
	. for leni=1:1:len-1 do
	.. set var=var_"a"
	set varname=var
	if $GET(pc) set varname="%"_var
	else  set varname="a"_var
	if 'subs set glvn=uparrow_varname
	if subs set glvn=uparrow_varname_"(1,2,3,""some subscripts"")"
	if len=maxlen  write " --> Testing ",glvn,!
	write @glvn
	if 'subs write @glvn@(1) write @glvn@(c)
	if "error"=exp write "ERROR-E-NOERROR, error was expected, but not seen",!
	quit
ERROR	;
	new $ZTRAP
	set $ZTRAP=""
	if "success"=exp  write "ERROR-E-UNEXPECTED error:exp=success:",$ZSTATUS,!
	if "error"=exp if $ZSTATUS'["UNDEF" write "ERROR-E-UNEXPECTED error: ",$ZSTATUS,!
	; write " encountered (expected) error for glvn: ",glvn," at line: ",line,":",$TEXT(@line),!
	zgoto $ZLEVEL-1
