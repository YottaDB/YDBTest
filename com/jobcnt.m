jobcnt();
	; Use evironment variable (unix) or logical (vms) gtm_test_jobcnt to find number of jobs to start
	; Default of jobcnt is 5
	set jobcnt=+$ztrnlnm("gtm_test_jobcnt")
	if jobcnt=0 set jobcnt=5
	w "jobcnt=",jobcnt,! 
	q jobcnt
