; -----------------------------------------------------------------------------------------------
; 			Trigger definitions for globals updated in fixtp.m
; -----------------------------------------------------------------------------------------------
;
; Note: The below trigger definitions relies heavily on the way slowfill.m creates global names. If ever the global name creation 
; method changes, then the corresponding trigger definition should also change.

-*
+^a(subs=:) -commands=SET -xecute="set (^b(subs),^c(subs))=$ztval"
+^b(subs=:) -commands=SET -xecute="set ^d(subs)=$ztval"
+^c(subs=:) -commands=SET -xecute="set (^e(subs),^f(subs))=$ztval"

; Determine if triggers are loaded.
;	set ^%fixtp("trigger")=0 write ^%fixtp("trigger"),!
; will produce 1 if triggers are enabled
+^%fixtp("trigger")               -commands=SET -xecute="set $ztvalue=$ztvalue+1"


; Below is the flow of triggered updates
; $ZTLEVEL=0:	^a(subs)=val
; $ZTLEVEL=1:		^b(subs)=val
; $ZTLEVEL=2:			^d(subs)=val
; $ZTLEVEL=1:		^c(subs)=val
; $ZTLEVEL=2:			^e(subs)=val
; $ZTLEVEL=2:			^f(subs)=val
; $ZTLEVEL=0:	^g(subs)=val
; $ZTLEVEL=0:	^h(subs)=val
; $ZTLEVEL=0:	^i(subs)=val
