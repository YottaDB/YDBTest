sectime	; convert seconds into hh:mm:ss
	; call as runsectime <secs>
	s sec=$ZCMDLINE
	s h=sec\3600
	s m=(sec-(h*3600))\60
	s s=sec#60
	s fn="sectime_tmp.com"
	o fn c fn:delete o fn u fn
	w "$ sectime :== ",h,":",m,":",s,!
	c fn
	h

