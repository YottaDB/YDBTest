;
; C9K10-003334 - External routine from C9K10003334b where we want to invoke a job interrupt
;                to test error handling.
;
C9K10003334c
	ZSystem "$gtm_dist/mupip intrpt "_$Job
	Hang 1	; Wait for job interrupt
	Quit
