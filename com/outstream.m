outsream()
	;
	; Filter for output files (outstream.log and subtest.log) using GT.M.
	;
	; Since Read and Write are to the same IO device, limited to STDIN input & STDOUT output.
	; Typical usage:
	;    cat subtest.log_actual | mumps -run %XCMD 'do ^outstream()' > subtest.log_m
	;

	; Increase maximum string length
	use $principal:width=1048576

	; Let any test have any free-form debugging info it wants, as long as it is padded with GTM_TEST_DEBUGINFO
	; Don't prepend with ##FILTERED## since outstream.awk will do it.
	;
	do repeol^awk("GTM_TEST_DEBUGINFO","GTM_TEST_DEBUGINFO.*")

	quit