updates(gvname)	;
	set tpcnt=0
	for i=1:1:1024  do
	. set istp=$random(2)
	. if istp=1 tstart ():serial
	. set var=gvname_"("_i_")"
	. set @var=$justify(i,1+$r(100))
	. if istp=1 tcommit  set tpcnt=tpcnt+1
	set file="settings.log"
	open file:(APPEND)
	use file
	write "No of tp transactions for gvname",gvname," : ",tpcnt,!
	close file
	quit
