bkgrndstop;
	set unix=$ZVersion'["VMS"
        if unix set pid=$J
	else  set pid=$$FUNC^%DH($J)
        set file="crash_job.out"
        open file:(newversion)
        use file
	write pid,!
	close file
	if unix zsy "source gtm_test_crash_jobs_0.csh"
	else  zsy "@gtm_test_crash_jobs_0.com"
	quit
