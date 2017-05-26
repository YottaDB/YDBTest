onlnread;
	set ^stop=0
	set unix=$ZVersion'["VMS"
        if unix set pid=$JOB
	else  set pid=$$FUNC^%DH($JOB)
        set file="concurrent_job.out"
        open file:(newversion)
        use file
	write pid,!
	close file
	for i=1:1  quit:^stop=1  do verify
	quit
verify	;
	do vergvt^upgrdtst   do verdirt^upgrdtst
	quit
