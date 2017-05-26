comm	;
	w !,"Testing commands/comments/local/global variations and jobbed processes...",!
	VIEW "TRACE":1:"^TRACE(""ZMPROF7"")"
	d ^comms
	VIEW "TRACE":0:"^TRACE(""ZMPROF7"")"
	;zwr ^TRACE("ZMPROF7",*)
	VIEW "TRACE":1:"^TRACE(""ZMPROF8"")"
	d ^one
	VIEW "TRACE":0:"^TRACE(""ZMPROF8"")"
	;zwr ^TRACE("ZMPROF8",*)
	VIEW "TRACE":1:"^TRACE(""ZMPROF9"")"
	w "do you count jobs?",!
	s unix=$zv'["VMS"
	if unix job ^one 
	else  job ^one:(nodet:startup="startup.com":output="one_job.out":error="one_job.err")
	w "tell me",!
	VIEW "TRACE":0:"^TRACE(""ZMPROF9"")"
	;zwr ^TRACE("ZMPROF9",*)
	VIEW "TRACE":1:"^TRACE(""ZMPROF10"")"
	s lcl=1
	s ^gbl=2
	f i=1:1:5 q:i>3  s a=i
	k a
	w "a"
	h 2
	VIEW "TRACE":0:"^TRACE(""ZMPROF10"")"
	;zwr ^TRACE("ZMPROF10",*)
	q
