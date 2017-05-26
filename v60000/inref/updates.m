; The below updates rely on the below
; * The journal pool size is limited to 1 MB
; * The db record and block sizes are 16128 and 32256 respectively
; Calculation of the below updates :
; jnlbuffer = 1048576 b ; single update = 8064 b ; therefore 131 updates will fill 1 MB buffer.
; 6 globals and 131*2 (262) updates = 12 MB Also an imptp process is also running in the background, which adds more updates
updates	; large updates to fill 1 MB jnlpool quickly
	for i=1:1:262 do
	. set val=$$^ulongstr(8064-i)
	. set val1=$justify(val,8064)
	. set ^aglobalvariable(i,$job)=val
	. set ^bglobal(i,$job)=val
	. set ^c(i,$job)=val
	. set ^dglobal(i)=val
	. set ^e=val
	. set ^fgbl($job)=val
	quit
