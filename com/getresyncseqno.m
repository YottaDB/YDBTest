	; this M routine will get the current journal seqno and resync seqno
	; for each instance. It will calculate a random seqno to use with
	; online rollback. You can pass in a floor which tells this routine to
	; not go beyond.
	; Usage:
	;   $gtm_exe/mumps -run getresyncseqno [$floor_seqno] >>&! roll_seqno.csh
	;   source roll_seqno.csh
	; Note the append in the redirection. This keeps track of each execution
	;
	; roll_seqno.csh contains the following TCSH variables:
	;   curr_jnl_seqno	- the current journal seqno
	;   curr_jnl_seqno_hex	- the current journal seqno in HEX
	;   curr_resync_seqnos	- the list of resync seqno's per instance
	;   roll_seqno		- the target rollback resync seqno
	;   roll_seqno_hex	- the target rollback resync seqno in HEX
getresyncseqno
resync
jnl
	new whichseqno,floorseqno
	set floorseqno=$piece($zcmdline," ",1)
	set floorseqno=$select(floorseqno?1.N:floorseqno,1:0)
	set whichseqno=$piece($zcmdline," ",2)
	if $length(whichseqno)=0 set whichseqno="jnl"
	do FUNC(whichseqno,floorseqno)
	quit

FUNC(whichseqno,floorseqno)
	new seqnostr,jnlseqno,rollseqno,jnlseqnohex,rollseqnohex,resyncseqnolist
	set seqnostr=$$getseqnos^getresyncseqno()
	write "# ",seqnostr,!
	XECUTE "set "_seqnostr
	set jnlseqnohex=$$FUNC^%DH(jnlseqno)
	set rollseqno=$select(whichseqno'="jnl":$piece(resyncseqnolist,",",1),1:jnlseqno)
	set rollseqno=$$rollseqno(rollseqno,floorseqno)
	set rollseqnohex=$$FUNC^%DH(rollseqno)
	if floorseqno>0,rollseqno>0  set floorseqno=floorseqno+((rollseqno-floorseqno)/2) ; raise the floor
	write:floorseqno "set floor_seq=",floorseqno,!
	write "set curr_jnl_seqno=",jnlseqno,!
	write "set curr_jnl_seqno_hex=",jnlseqnohex,!
	write "set curr_resync_seqnos=",$c(34),resyncseqnolist,$c(34),!
	write "set roll_seqno=",rollseqno,!
	write "set roll_seqno_hex=",rollseqnohex,!
	quit

	; this routine takes a seqno and throws it back in time by some factor
rollseqno(seqno,floor)
	new mode,rolseqno,nomax,nomin
	set mode=$random(20),rolseqno=seqno-floor
	; interesting rollback conditions		; ENV VARs avoid these cases
	set nomax=+$ztrnlnm("gtm_test_online_rollback_no_max_seqno")
	if 'nomax quit:(mode=5) (floor+(2*seqno))	; should be true max seqno
	set nomin=+$ztrnlnm("gtm_test_online_rollback_no_min_seqno")
	if 'nomin quit:(mode=7) (floor+1)		; rollback to floor - inflict massive pain
	; Generate the rollback seqno based on the current seqno
	set seqno=(rolseqno\2)+1			; 40%
	set:(mode=2) seqno=(rolseqno\4)+1		; 10%
	set:(mode#3)=0 seqno=((2*seqno\3))+1 		; 30%
	set:(mode#4)=0 seqno=(3*(rolseqno\4))+1		; 20%
	quit (floor+seqno)

	; execute $MUPIP replic -editinstance -show and pass the output
	; to process^replinst to grab the "Resync Sequence Number" field
getcurseqno(whichseqno)
	new fields,pipe,i,inst,instlist,file,$ETRAP
	set $ETRAP="do debug"
	if $data(whichseqno)=0 set whichseqno="resync"
	set seqnocmd=$piece($text(mupipcmds+2^getresyncseqno),";",2)
	set pipe="pipe"
	open pipe:(command=seqnocmd)::"pipe"
	use pipe
	for i=1:1 quit:$zeof  read line(i)  do process^replinst(line(i),.fields)
	close pipe
	quit:whichseqno="jnl" fields("CTL","Journal Seqno")
	; whichseqno="resync" ; need to get the list of instance to seqnos
	for inst=0:1:6  quit:$data(fields("SLT",inst,"Resync Sequence Number"))=0  do
	.	set $piece(instlist,",",inst+1)=fields("SLT",inst,"Resync Sequence Number")
	if $data(instlist)=0 do debug
	if $data(^debug)>0 do debug
	quit instlist
	
	; execute $MUPIP replic -editinstance -show and pass the output
	; to process^replinst to grab the sequence # fields
getseqnos()
	new fields,pipe,i,inst,instlist,file,xstr
	set seqnocmd=$piece($text(mupipcmds+2^getresyncseqno),";",2)
	set pipe="pipe"
	open pipe:(command=seqnocmd)::"pipe"
	use pipe
	for i=1:1 quit:$zeof  read line(i)  do process^replinst(line(i),.fields)
	close pipe
	set xstr="jnlseqno="_fields("CTL","Journal Seqno")
	for inst=0:1:6  quit:$data(fields("SLT",inst,"Resync Sequence Number"))=0  do
	.	set $piece(instlist,",",inst+1)=fields("SLT",inst,"Resync Sequence Number")
	if $data(instlist)=0 do debug
	set $piece(xstr,",",2)="resyncseqnolist="""_instlist_""""
	if $data(^debug)>0 do debug
	quit xstr

	; when a failure occurs dump information to separate file
debug
	new file
	set file="getresyncseqno.debug"
	open file:append
	use file
	zshow "*"
	set:$ecode'="" $ecode=""
	close file
	quit

usingthedebuginfo
	; if instlist is NULL, the use this to figure out what went wrong:
	; zgrep '^line' getresyncseqno.debug.gz | sed -e 's/^[^=]*=.//' -e 's/.$//' > getresyncseqno.debug
	; set file="getresyncseqno.debug" open file use file for i=1:1 quit:$zeof  read line(i)  do process^replinst(line(i),.fields)
	; zwrite fields
	quit

mupipcmds
	;$MUPIP replic -editinstance    -show $gtm_repl_instance;
	;$MUPIP replic -source -jnlpool -show                   ;
