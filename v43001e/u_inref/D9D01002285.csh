#!/usr/local/bin/tcsh -f

#	test that ZSTEP OVER does transfer control to the correct M statement

$GTM << GTM_EOF
	do ^d002285
	zstep over
	zstep over
	zstep over
GTM_EOF
