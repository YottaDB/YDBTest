; Basic test for triggers with SN.
; Called from trigger.csh.
trig
	write "#Kill trigger",!
	set ^nsgblbackup=100
	set span="1"_$justify(" ",3000)
	set ^nsgbl=span
 	kill ^nsgbl
 	if ^nsgblbackup'=span write "Error! ^nsgbl trigger didn't work right",!
	write "#Nested set trigger",!
	set ^one=^nsgblbackup
	if (@("^one")_@("^two")_@("^three")_@("^four"))'=("changedztval"_span_234) write "Error! ^one set trigger didn't work right",!
	write "#Nested kill trigger",!
	kill ^one
	if $data(@("^two")),$data(@("^three")),$data(@("^four"))'="000" write "Error! ^one kill trigger didn't work right",!
	;
	;----------------------------------------------------------------------------------------
	; Check that gvcst_dataget correctly determines $ztdata and $ztold for spanning nodes
	;----------------------------------------------------------------------------------------
	;
	write "#Test dataget",!
	;
	set ^x(1)=span				; setup ztdata for following trigger invocation
	kill ^ztx
	set ^x=span
	set right="$ztold "_$select((""=^ztx("S","ztold")):"correct",1:"incorrect")
	write "$ztdata="_^ztx("S","ztdata")_"; "_right,!				; expect $ztdata=0 and $ztold=""
	;
	kill ^ztx
	set ^x=span
	set right="$ztold "_$select((span=^ztx("S","ztold")):"correct",1:"incorrect")
	write "$ztdata="_^ztx("S","ztdata")_"; "_right,!				; expect $ztdata=1 and $ztold=span
	;
	kill ^ztx
	kill ^x
	set right="$ztold "_$select((span=^ztx("K","ztold")):"correct",1:"incorrect")
	write "$ztdata="_^ztx("K","ztdata")_"; "_right,!				; expect $ztdata=11 and $ztold=span
	;
	set ^x=span				; setup ztdata
	kill ^ztx
	kill ^x
	set right="$ztold "_$select((span=^ztx("K","ztold")):"correct",1:"incorrect")
	write "$ztdata="_^ztx("K","ztdata")_"; "_right,!				; expect $ztdata=1 and $ztold=span
	;
	set ^x(1)=span				; setup ztdata
	kill ^ztx
	kill ^x
	set right="$ztold "_$select((""=^ztx("K","ztold")):"correct",1:"incorrect")
	write "$ztdata="_^ztx("K","ztdata")_"; "_right,!				; expect $ztdata=10 and $ztold=""
	;
	set ^x("",2)=span,^x=span		; setup ztdata
	kill ^ztx
	kill ^x
	set right="$ztold "_$select((span=^ztx("K","ztold")):"correct",1:"incorrect")
	write "$ztdata="_^ztx("K","ztdata")_"; "_right,!				; expect $ztdata=11 and $ztold=span
	;
	; Try some situations with ztold=$c(0). This tests the spanning node code path since $c(0) is the value of
	; the dummy node for spanning nodes. Make sure that ztold is correctly returned as $c(0).
	;
	kill ^x set ^x=$c(0)			; setup ztdata
	kill ^ztx
	kill ^x
	set right="$ztold "_$select(($c(0)=^ztx("K","ztold")):"correct",1:"incorrect")
	write "$ztdata="_^ztx("K","ztdata")_"; "_right,!				; expect $ztdata=1 and $ztold=$c(0)
	;
	kill ^x set ^x=$c(0),^x(1)=$c(0)	; setup ztdata
	kill ^ztx
	kill ^x
	set right="$ztold "_$select(($c(0)=^ztx("K","ztold")):"correct",1:"incorrect")
	write "$ztdata="_^ztx("K","ztdata")_"; "_right,!				; expect $ztdata=11 and $ztold=$c(0)
	;
	quit
