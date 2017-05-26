; Secondary routine for testing C9J06-003137
;
; This routine does a meaningless MERGE command which sets the restartpc in this module.
;
	New b,bprime,indx
	Set bprime(1)=a(1)
	Set indx=1
	Merge b=bprime(indx)
	Set indx=b
	Quit
