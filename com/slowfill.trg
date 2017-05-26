; -----------------------------------------------------------------------------------------------
; 		Trigger definitions for globals updated in slowfill.m
; -----------------------------------------------------------------------------------------------
; Note:
; 1. The below trigger definitions relies heavily on the way slowfill.m creates global names. If ever the global name creation method
; changes, then the corresponding trigger definition should also change.
; 2. The trigger definition assumes that there are only two subscripts involved. This is because, slowfill.m uses only two subscripts 
; as long as gtm_test_dbfillid is not set in the calling test script. As of now, only 2-3 tests sets gtm_test_dbfillid and hence the 
; below trigger definitions.
-*
+^atpslowfilling(fillid=:,subs=:) -commands=SET -xecute="set ^btpslowfilling(fillid,subs)=$ztval set ^ctpslowfilling(fillid,subs)=$ztval"
+^btpslowfilling(fillid=:,subs=:) -commands=SET -xecute="set (^dtpslowfilling(fillid,subs),^etpslowfilling(fillid,subs),^ftpslowfilling(fillid,subs))=$ztval"
+^ctpslowfilling(fillid=:,subs=:) -commands=SET -xecute="set (^gtpslowfilling(fillid,subs),^htpslowfilling(fillid,subs),^itpslowfilling(fillid,subs))=$ztval"

; Below is the flow of triggered updates
;$ZTLEVEL=0:	^atpslowfilling(fillid,subs)=val
;$ZTLEVEL=1: 		^btpslowfilling(fillid,subs)=val
;$ZTLEVEL=2:			^dtpslowfilling(fillid,subs)=val
;$ZTLEVEL=2:			^etpslowfilling(fillid,subs)=val
;$ZTLEVEL=2:			^ftpslowfilling(fillid,subs)=val
;$ZTLEVEL=1:		^ctpslowfilling(fillid,subs)=val
;$ZTLEVEL=2:			^gtpslowfilling(fillid,subs)=val
;$ZTLEVEL=2:			^htpslowfilling(fillid,subs)=val
;$ZTLEVEL=2:			^itpslowfilling(fillid,subs)=val

; Determine if triggers are loaded.
;	set ^%slowfill("trigger")=0 write ^%slowfill("trigger"),!
; will produce 1 if triggers are enabled
+^%slowfill("trigger")               -commands=SET -xecute="set $ztvalue=$ztvalue+1"

