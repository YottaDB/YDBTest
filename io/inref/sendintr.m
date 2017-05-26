sendintr(type)
	; The purpose this function is to interrupt the read process until we are requested to shutdown or we reach a system
	; defined limit of interrupts or number of loops attempting to send the interrupt.  If we ever reach this limit it
	; probably means we were orphaned and are just chewing up cpu time.
	; It is passed a parameter of this same type to be used in globals such as ^loopcnt(type) where it stores the 
	; number of loops in case the read process dies without setting ^quit.  If this happens $ZSigproc will fail
	; and not increment ^NumIntrSent(type).  Otherwise ^NumIntrSent(type) will contain the number of interrupts sent
	; to the read process.  This function is used by both fifointrdriver.m and intrdriver.m.
	set p=type_"_send_pid"
	open p:newversion
	use p
	write $job,!
	close p
	set ^loopcnt(type)=0
	Write "Interrupt rate chosen - Minimum: ",^minsnooze/10000,"  Maximum: ",^maxsnooze/10000,"  Signum: ",^signum,!
	for  do  quit:$data(^doreadpid(type))
	; wait up to 30 sec for first read before sending interrupts	    
	set readdone=0
	for i=1:1:30 do  quit:readdone
	. hang 1
	. if $data(^readcnt(type))&(1<^readcnt(type)) set readdone=1
	for  do  quit:$data(^quit)!(20000=^NumIntrSent(type))!(20000=^loopcnt(type))
	. if '$ZSigproc(^doreadpid(type),^signum) set ^NumIntrSent(type)=^NumIntrSent(type)+1
	. Hang ($Random(^maxsnooze-^minsnooze)+^minsnooze)/10000
	. set ^loopcnt(type)=^loopcnt(type)+1
	if (20000=^NumIntrSent(type))!(20000=^loopcnt(type)) set ^quit=1
	write "Number of interrupts sent = ",^NumIntrSent(type),!
	write "loop count = ",^loopcnt(type),!
