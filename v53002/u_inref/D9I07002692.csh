#!/usr/local/bin/tcsh
#
# D9I07-002692 test of zprint with an object-source mismatch
#
\cp $gtm_tst/$tst/inref/d002692.m foo.m
$gtm_exe/mumps -object=d002692.o foo.m
$GTM <<GTM_EOF
	zprint +0^d002692
	write !,"Pass from D9I07002692"
GTM_EOF
