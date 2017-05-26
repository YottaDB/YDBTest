c003006	;
	; Test that whenever "frame_pointer" or "->old_frame_pointer" gets adjusted,
	;	"error_frame" gets correspondingly adjusted if it points to the same location.
	; In order to test this, make sure a runtime error happens in an indirect frame (uncounted).
	; Make sure the error trap does one of the following as these trigger the frame_pointer adjustment.
	;	NEW of Intrinsic Special Variable
	;	NEW of a local variable
	;	TSTART
	;	Exclusive NEW
	; Out of the above, a TSTART does the adjustment only if the frame before the erroring frame is the direct-mode frame
	;	so it is hard to reproduce the issue (in previous versions of GT.M) in this case. Nevertheless we have this
	;	also tested just to be safe it works right.
	;
test1	;
	set $etrap="write $zstatus,! new $zyerror Q"
	do helper
	quit
test2	;
	set $etrap="write $zstatus,! new x Q"
	do helper
	quit
test3	;
	kill ^tc
	set $etrap="write $zstatus,! tstart ():serial  set ^tc=$get(^tc)+1  tcommit  Q"
	do helper
	quit
test4	;
	set $etrap="write $zstatus,! new  Q"
	do helper
	quit
helper	;
	S ref="^gbl(undef)"
	write $order(@ref),!
	quit
